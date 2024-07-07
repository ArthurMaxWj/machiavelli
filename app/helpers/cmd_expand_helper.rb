module CmdExpandHelper
def command_list
    %i[n m p b]
end

def expand_command(cmd)
    {
       n: '[n] New combination (3, 0, 0)',
       m: '[m] Move card (1, 1, 0)',
       p: '[p] Put card (0, 0,1)',
       b: '[b] Break combination (0, 1, 0)'
    }[cmd]
end

end
