byte(n) return(n&0xff);

assert(expr, msg) {
    extrn puts, abort;
    puts(msg);
    abort();
}

read_int(file) {
    extrn fgetc, isdigit;
    auto res, s;

    res = 0;
    while (1) {
        s = fgetc(file);
        if (!isdigit(s)) goto end;
        res = res*10 + (s - '0');
    }

end:
    return(res);
}

str2int(ptr, result) {
    extrn isdigit;
    auto n;

    n = 0;
    while (1) {
        if (!isdigit(byte(*ptr))) goto end;
        n = n*10 + (byte(*ptr) - '0');
        ptr += 1;
    }

end:
    *result = n;
    return(ptr);
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
    extrn printf, abort;

    auto buf; buf = read_entire_file("input.txt");
    auto ptr; ptr = buf;

    auto dial; dial = 50;
    auto answer; answer = 0;
    while (byte(*ptr) != 0) {
        auto dir; dir = byte(*ptr++);
        auto n;
        ptr = str2int(ptr, &n) + 1;
        printf("%c%zu\n", dir, n);

        if (dial < 0) {
            printf("Error %zu\n", dial);
            abort();
        }
        if (dial > 99) {
            printf("Error %zu\n", dial);
            abort();
        }

        while (n > 100) {
            n -= 100;
            answer += 1;
        }

        if (dir == 'L') {
            if (dial < n) {
                if (dial != 0) answer += 1;
                dial = 99 - (n - dial - 1);
            } else {
                dial -= n;
            }
        } else if (dir == 'R') {
            dial += n;
            if (dial > 99) {
                dial -= 100;
                if (dial != 0) answer += 1;
            }
        }

        if (dial == 0) {
            answer += 1;
        }
    }

    printf("Answer: %zu\n", answer);
}
