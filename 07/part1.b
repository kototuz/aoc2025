MAP_WIDTH;
MAP_HEIGHT;
MAP;

assert(expr, msg) {
    extrn abort;
    if (!expr) {
        printf("ASSERTION FAILED: %s\n", msg);
        abort();
    }
}

read_entire_file(file_name, res_size) {
    extrn fopen, fclose, fseek, rewind, ftell, malloc, fread, printf, feof;
    auto file, file_size, i, buf;

    file = fopen(file_name, "r");
    fseek(file, 0, 2);
    file_size = ftell(file) + 1;
    rewind(file);

    buf = malloc(file_size);
    fread(buf, file_size, file_size, file);
    fclose(file);

    *(buf+file_size) = 0x0;
    if (res_size != 0) {
        *res_size = file_size;
    }

    return(buf);
}

load_map(file_path) {
    auto size;
    MAP = read_entire_file(file_path, &size);
    MAP_WIDTH = 0; while (char(MAP, MAP_WIDTH) != '\n') MAP_WIDTH++;
    MAP_HEIGHT = size/(MAP_WIDTH+1);
    printf("\ninfo: loaded map %zux%zu\n\n", MAP_WIDTH, MAP_HEIGHT);
}

get(x, y) {
    if (x >= MAP_WIDTH | y >= MAP_HEIGHT) return(0);
    return(char(MAP, (MAP_WIDTH+1)*y + x));
}

set(x, y, c) {
    assert(x < MAP_WIDTH & y < MAP_HEIGHT, "Invalid coordinates");
    lchar(MAP, (MAP_WIDTH+1)*y + x, c);
}

main() {
    load_map("input.txt");

    set((MAP_WIDTH-1)/2, 1, '|');

    auto x, y, answer;
    answer = 0;
    y = 1; while (y < MAP_HEIGHT) {
        x = 0; while (x < MAP_WIDTH) {
            if (get(x, y) == '|') {
                if (get(x, y+1) == '.') {
                    set(x, y+1, '|');
                } else if (get(x, y+1) == '^') {
                    answer += 1;
                    assert(get(x-1, y+1) != '^', "Unexpected ^");
                    assert(get(x+1, y+1) != '^', "Unexpected ^");
                    set(x-1, y+1, '|');
                    set(x+1, y+1, '|');
                }
            }

            x += 1;
        }

        y += 1;
    }

    printf("%s", MAP);
    printf("Answer=%zu\n", answer);
}
