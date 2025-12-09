MAP_WIDTH;
MAP_HEIGHT;
MAP;
TIMELINE_MAP;

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

get_tl(x, y) {
    assert(x < MAP_WIDTH & y < MAP_HEIGHT, "Invalid coordinates");
    return(TIMELINE_MAP[MAP_WIDTH*y + x]);
}

set_tl(x, y, tl_count) {
    assert(x < MAP_WIDTH & y < MAP_HEIGHT, "Invalid coordinates");
    TIMELINE_MAP[MAP_WIDTH*y + x] = tl_count;
}

add_tl(x, y, tl_count) {
    assert(x < MAP_WIDTH & y < MAP_HEIGHT, "Invalid coordinates");
    TIMELINE_MAP[MAP_WIDTH*y + x] += tl_count;
}

main() {
    extrn malloc, memset;

    load_map("input.txt");
    TIMELINE_MAP = malloc(MAP_WIDTH*MAP_HEIGHT * &0[1]);
    memset(TIMELINE_MAP, 0, MAP_WIDTH*MAP_HEIGHT * &0[1]);

    set((MAP_WIDTH-1)/2, 1, '|');
    set_tl((MAP_WIDTH-1)/2, 1, 1);

    auto x, y, answer;
    y = 1; while (y < MAP_HEIGHT) {
        x = 0; while (x < MAP_WIDTH) {
            if (get(x, y) == '|') {
                if (get(x, y+1) == '.') {
                    set(x, y+1, '|');
                    add_tl(x, y+1, get_tl(x, y));
                } else if (get(x, y+1) == '^') {
                    assert(get(x-1, y+1) != '^', "Unexpected ^");
                    assert(get(x+1, y+1) != '^', "Unexpected ^");
                    set(x-1, y+1, '|');
                    set(x+1, y+1, '|');
                    add_tl(x-1, y+1, get_tl(x, y));
                    add_tl(x+1, y+1, get_tl(x, y));
                } else if (get(x, y+1) == '|') {
                    add_tl(x, y+1, get_tl(x, y));
                }
            }

            x += 1;
        }

        y += 1;
    }

    y = MAP_HEIGHT-1;
    x = 0; while (x < MAP_WIDTH) {
        answer += get_tl(x, y);
        x += 1;
    }

    printf("Answer=%zu\n", answer);
}
