MAP_SIZE;
MAP_LEN;
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
        *res_size = file_size - 1;
    }

    return(buf);
}

get(x, y) {
    if (x >= MAP_SIZE | y >= MAP_SIZE) return(0);
    return(char(MAP, (MAP_SIZE+1)*y + x));
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
    MAP_SIZE = 138;
    MAP = read_entire_file("input.txt", &MAP_LEN);

    auto x, y, answer; answer = 0;
    y = 0; while (y < MAP_SIZE) {
        x = 0; while (x < MAP_SIZE) {
            if (get(x, y) == '@') {
                if (count_nbors(x, y) < 4) {
                    answer += 1;
                }
            }
            x += 1;
        }
        y += 1;
    }

    printf("Answer=%zu\n", answer);
}
