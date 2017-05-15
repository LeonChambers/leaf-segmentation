require 'nn'
require 'nngraph'
require 'torch'
require 'image'
require 'cunn'

xSize = 106
ySize = 100
seq_length = 30

cmd = torch.CmdLine()
cmd:option('-name', 'experiment', 'Name of the experiment')
cmd:option('-data_dir', '.', 'Data directory')
cmd:option('-config_dir', '.', 'Config directory')
cmd:option('-gpumode', 1, 'Run on GPU')
cmd:option('-rnn_channels', 30, 'Number of RNN channels')
cmd:option('-rnn_layers', 2, 'Number of RNN layers')

cmd_params = cmd:parse(arg)

gpumode = cmd_params.gpumode

input_list_file = io.open(cmd_params.data_dir .. 'input_list.txt', "r")
output_list_file = io.open(cmd_params.data_dir .. 'output_list.txt', "r")

function nextPaths()
    io.input(input_list_file)
    input_file = io.read()
    if input_file==nil then
        return nil, nil
    end
    io.input(output_list_file)
    output_file = io.read()
    return input_file, output_file
end

function readImage(input_file)
    local input_image = image.load(cmd_params.data_dir .. input_file):sub(1,3)

    input_image = torch.reshape(image.scale(input_image, ySize, xSize):float(), 3, xSize, ySize)

    if gpumode==1 then
        input_image = input_image:cuda()
    end

    return input_image
end

model = torch.load(cmd_params.config_dir .. 'plants_pre_lstm.model')
protos = torch.load(cmd_params.config_dir .. 'plants_convlstm.model')

local init_state_global = {}
for L=1,cmd_params.rnn_layers do
    local h_init = torch.zeros(cmd_params.rnn_channels, xSize, ySize)
    if gpumode==1 then h_init = h_init:cuda() end
    table.insert(init_state_global, h_init:clone())
    table.insert(init_state_global, h_init:clone())
end

input_file, output_file = nextPaths()
while input_file ~= nil do
    input_image = readImage(input_file)

    x = model:forward(input_image)

    local current_state = {}
    current_state = init_state_global
    prediction = {}
    solutions = torch.zeros(seq_length, xSize, ySize)
    local counter = 0
    for t=1,seq_length do
        local lst = protos.rnn:forward({x, unpack(current_state)})

        current_state = {}
        for i=1,#init_state_global do table.insert(current_state, lst[i]) end
        local prediction = lst[#lst]
        local postlst = protos.post_lstm:forward(prediction)
        output = postlst[1]:clone()
        output:resize(1, xSize, ySize)
        degree = postlst[2]

        if degree[1]<0.5 then
            break
        end
        counter = counter+1

        solutions[{t,{},{}}] = output:double()
    end

    canvas = torch.zeros(xSize, ySize)
    for t=counter,1,-1 do
        canvas[solutions:sub(t,t):gt(0.9)] = t
        --canvas[solutions:select(1,t):gt(0.9)] = t
    end

    image.save(cmd_params.data_dir .. output_file, canvas)

    input_file, output_file = nextPaths()
end
