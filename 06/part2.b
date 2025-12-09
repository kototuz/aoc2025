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
    return(char(MAP, (MAP_WIDTH+1)*y + x));
}

set(x, y, sym) {
    assert(x < MAP_WIDTH & y < MAP_HEIGHT, "Invalid coordinates");
    lchar(MAP, (MAP_WIDTH+1)*y + x, sym);
}

has_digits(x) {
    auto res; res = 0;
    auto y; y = 0; while (y < MAP_HEIGHT-1) {
        if (get(x, y) != ' ') res = 1;
        y += 1;
    }
    return(res);
}

calc_num(x, out) {
    auto y;
    auto has_digits; has_digits = 0;
    y = 0; while (y < MAP_HEIGHT-1) {
        if (get(x, y) != ' ') has_digits = 1;
        y += 1;
    }

    if (!has_digits) return(0);

    auto res; res = 0;
    y = 0; while (y < MAP_HEIGHT-1) {
        auto sym; sym = get(x, y);
        if (sym != ' ') {
            res = 10*res + (sym - '0');
        }
        y += 1;
    }

    *out = res;
    return(1);
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
    MAP_WIDTH = 3684;
    MAP_HEIGHT = 5;
    MAP = read_entire_file("input.txt");
    auto ptr; ptr = MAP;

    auto x, n, op, expr_res, answer;
    x = 0; answer = 0; while (1) {
        op = get(x, MAP_HEIGHT-1);
        printf("%c\n", op);
        if (op == '*') {
            expr_res = 1;
            while (calc_num(x, &n)) {
                printf("%zu\n", n);
                expr_res *= n;
                x += 1;
                if (x >= MAP_WIDTH) {
                    answer += expr_res;
                    goto break;
                }
            }
        } else {
            expr_res = 0;
            while (calc_num(x, &n)) {
                printf("%zu\n", n);
                expr_res += n;
                x += 1;
                if (x >= MAP_WIDTH) {
                    answer += expr_res;
                    goto break;
                }
            }
        }

        answer += expr_res;
        x += 1;
    }

break:
    printf("Answer=%zu\n", answer);


    // auto x, y, n, n_begin;
    // y = 0; while (y < MAP_HEIGHT-1) {
    //     x = 0; while (x < MAP_WIDTH) {
    //         while (char(ptr, 0) == ' ') ptr++;
    //         n_begin = ptr;
    //         ptr = str2int(ptr, &n);
    //         set_str(x, y, n_begin, ptr);
    //         x += 1;
    //     }
    //
    //     while (char(ptr++, 0) != '\n');
    //     y += 1;
    // }
    //
    // y = MAP_HEIGHT-1;
    // x = 0; while (x < MAP_WIDTH) {
    //     while (char(ptr, 0) == ' ') ptr++;
    //     set(x, y, char(ptr, 0));
    //     ptr += 1;
    //     x += 1;
    // }
    //
    // auto answer; answer = 0;
    // x = 0; while (x < MAP_WIDTH) {
    //     auto res, col, n;
    //     auto op; op = get(x, MAP_HEIGHT-1);
    //     printf("%c\n", op);
    //     if (op == '*') {
    //         res = 1;
    //         col = 0; while (col < NUM_SIZE) {
    //             if (calc_num(x, col++, &n)) {
    //                 printf("%zu\n", n);
    //                 res *= n;
    //             }
    //         }
    //     } else {
    //         res = 0;
    //         col = 0; while (col < NUM_SIZE) {
    //             if (calc_num(x, col++, &n)) {
    //                 printf("%zu\n", n);
    //                 res += n;
    //             }
    //         }
    //     }
    //     printf("\n");
    //
    //     answer += res;
    //     x += 1;
    // }
    //
    // printf("Answer=%zu\n", answer);
}
