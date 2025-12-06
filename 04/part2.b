MAP_SIZE;
MAP_LEN;
RMAP;
WMAP;

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
        *res_size = file_size - 1;
    }

    return(buf);
}

get(x, y) {
    if (x >= MAP_SIZE | y >= MAP_SIZE) return(0);
    return(char(RMAP, (MAP_SIZE+1)*y + x));
}

set(x, y, sym) {
    assert(x < MAP_SIZE & y < MAP_SIZE, "Invalid coordinates");
    lchar(WMAP, (MAP_SIZE+1)*y + x, sym);
}

count_nbors(x, y) {
    auto res; res = 0;
    if (get(x-1, y-1) == '@') res += 1;
    if (get(x, y-1) == '@')   res += 1;
    if (get(x+1, y-1) == '@') res += 1;
    if (get(x-1, y) == '@')   res += 1;
    if (get(x+1, y) == '@')   res += 1;
    if (get(x-1, y+1) == '@') res += 1;
    if (get(x, y+1) == '@')   res += 1;
    if (get(x+1, y+1) == '@') res += 1;
    return(res);
}

main() {
    extrn memcpy, malloc;

    MAP_SIZE = 138;
    RMAP = read_entire_file("input.txt", &MAP_LEN);
    WMAP = malloc(MAP_LEN);
    memcpy(WMAP, RMAP, MAP_LEN);

    auto x, y, answer; answer = 0;

    auto removed; removed = 1; 
    while (removed > 0) {
        removed = 0;
        y = 0; while (y < MAP_SIZE) {
            x = 0; while (x < MAP_SIZE) {
                if (get(x, y) == '@') {
                    if (count_nbors(x, y) < 4) {
                        removed += 1;
                        set(x, y, 'x');
                    }
                }
                x += 1;
            }
            y += 1;
        }

        memcpy(RMAP, WMAP, MAP_LEN);

        printf("%s", RMAP);
        printf("removed=%zu\n\n", removed);

        answer += removed;
    }

    printf("Answer=%zu\n", answer);
}
