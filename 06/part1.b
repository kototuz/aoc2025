MAP_WIDTH;
MAP_HEIGHT;
MAP[5000];

assert(expr, msg) {
    extrn abort;
    if (!expr) {
        printf("ASSERTION FAILED: %s\n", msg);
        abort();
    }
}

str2int(ptr, result) {
    extrn isdigit;
    auto n; n = 0;
    while (1) {
        if (!isdigit(char(ptr, 0))) {
            *result = n;
            return(ptr);
        }

        n = n*10 + (char(ptr, 0) - '0');
        ptr += 1;
    }
}

get(x, y) {
    assert(x < MAP_WIDTH & y < MAP_HEIGHT, "Invalid coordinates");
    return(MAP[MAP_WIDTH*y + x]);
}

set(x, y, n) {
    assert(x < MAP_WIDTH & y < MAP_HEIGHT, "Invalid coordinates");
    MAP[MAP_WIDTH*y + x] = n;
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

main() {
    MAP_WIDTH = 1000;
    MAP_HEIGHT = 5;
    auto input; input = read_entire_file("input.txt");
    auto ptr; ptr = input;

    auto x, y, n;
    y = 0; while (y < MAP_HEIGHT-1) {
        x = 0; while (x < MAP_WIDTH) {
            while (char(ptr, 0) == ' ') ptr++;
            ptr = str2int(ptr, &n);
            set(x, y, n);
            x += 1;
        }

        while (char(ptr++, 0) != '\n');
        y += 1;
    }

    y = MAP_HEIGHT-1;
    x = 0; while (x < MAP_WIDTH) {
        while (char(ptr, 0) == ' ') ptr++;
        set(x, y, char(ptr, 0));
        ptr += 1;
        x += 1;
    }

    auto answer; answer = 0;
    x = 0; while (x < MAP_WIDTH) {
        auto res;
        auto op; op = get(x, MAP_HEIGHT-1);
        if (op == '*') {
            res = 1;
            y = 0; while (y < MAP_HEIGHT-1) res *= get(x, y++);
        } else {
            res = 0;
            y = 0; while (y < MAP_HEIGHT-1) res += get(x, y++);
        }

        answer += res;
        x += 1;
    }

    printf("Answer=%zu\n", answer);
}
