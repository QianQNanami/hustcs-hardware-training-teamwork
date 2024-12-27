line = 48
column = 60
# line = 2
# column = 3
wall = '#'
path = '.'
start = 'S'
color = {
    '#': 'F00',
    '.': '0F0',
    'E': 'FFF',
    'S': '00F'
}

with open('./maze.txt') as f:
    maze = f.read().splitlines()
    
assert(len(maze) == line)
verilog = []
for i in range(line):
    assert(len(maze[i]) == column)
    for j in range(column):
        sentence = f'mem[{i*64+j}] = 32\'h{color[maze[i][j]]};'
        verilog.append(sentence)

with open('./maze2verilog.txt', 'w') as f:
    f.write('\n'.join(verilog))