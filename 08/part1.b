WORD_SIZE;

NUMBERS; NUMBERS_CAP; NUMBER_COUNT 0;

BOXES; BOXES_CAP; BOX_COUNT  0;
X 0; Y 1; Z 2;

PAIRS; PAIRS_CAP; PAIR_COUNT 0;
A 0; B 1; DISTANCE 2;

assert(expr, msg) {
    extrn abort;
    if (!expr) {
        printf("ASSERTION FAILED: %s\n", msg);
        abort();
    }
}

ITEMS 0; COUNT 1; CAPACITY 2;
da_append(da, x) {
    extrn realloc;
    if (da[COUNT] >= da[CAPACITY]) {
        if (da[CAPACITY]) da[CAPACITY] *= 2;
        else da[CAPACITY] = 256;

        da[ITEMS] = realloc(da[ITEMS], da[CAPACITY] * WORD_SIZE);
    }
    da[ITEMS][da[COUNT]++] = x;
}

da_append_many(da, xs, count) {
    extrn realloc, memcpy;
    if (da[COUNT]+count > da[CAPACITY]) {
        da[CAPACITY] = da[COUNT] + count;
        da[ITEMS] = realloc(da[ITEMS], da[CAPACITY] * WORD_SIZE);
    }
    memcpy(&da[ITEMS][da[COUNT]], xs, count*WORD_SIZE);
    da[COUNT] += count;
}

read_entire_file(file_name, res_size) {
    extrn fopen, fclose, fseek, rewind, ftell, malloc, memset, fread;
    auto file, file_size, buf;

    file = fopen(file_name, "r");
    fseek(file, 0, 2);
    file_size = ftell(file) + 1;
    rewind(file);

    buf = malloc(file_size);
    memset(buf, 0, file_size);
    fread(buf, file_size, file_size, file);
    fclose(file);

    if (res_size != 0) {
        *res_size = file_size;
    }

    return(buf);
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

push_box(x, y, z) {
    auto new_box;
    assert(BOX_COUNT < BOXES_CAP, "BOXES overflowed");
    new_box = &NUMBERS[NUMBER_COUNT];
    new_box[X] = x; NUMBER_COUNT++;
    new_box[Y] = y; NUMBER_COUNT++;
    new_box[Z] = z; NUMBER_COUNT++;
    BOXES[BOX_COUNT++] = new_box;
}

push_pair(box1, box2, distance) {
    auto new_pair;
    assert(PAIR_COUNT < PAIRS_CAP, "PAIRS overflowed");
    new_pair = &NUMBERS[NUMBER_COUNT];
    new_pair[A] = box1; NUMBER_COUNT++;
    new_pair[B] = box2; NUMBER_COUNT++;
    new_pair[DISTANCE] = distance; NUMBER_COUNT++;
    PAIRS[PAIR_COUNT++] = new_pair;
}

load_boxes(file_path) {
    extrn free;
    auto data, ptr, x, y, z;
    data = read_entire_file(file_path, 0);
    ptr = data;
    while (char(ptr, 0) != '\0') {
        ptr = str2int(ptr, &x) + 1;
        ptr = str2int(ptr, &y) + 1;
        ptr = str2int(ptr, &z) + 1;
        push_box(x, y, z);
    }
    free(data);
}

make_pairs() {
    extrn ddist3d;
    auto i, j, dist, box_a, box_b;
    i = 0; while (i < BOX_COUNT) {
        box_a = BOXES[i];
        j = i+1; while (j < BOX_COUNT) {
            box_b = BOXES[j];
            dist = ddist3d(box_a[X], box_a[Y], box_a[Z], box_b[X], box_b[Y], box_b[Z]);
            push_pair(box_a, box_b, dist);
            j += 1;
        }
        i += 1;
    }
}

find_n_min_distances(n) {
    extrn dless, dconst;
    auto i, j, idx_min;
    i = 0; while (i < n) {
        idx_min = i;
        j = i+1; while (j < PAIR_COUNT) {
            if (dless(PAIRS[j][DISTANCE], PAIRS[idx_min][DISTANCE])) {
                idx_min = j;
            }
            j += 1;
        }

        PAIRS[i][A] = PAIRS[idx_min][A];
        PAIRS[i][B] = PAIRS[idx_min][B];
        PAIRS[i][DISTANCE] = PAIRS[idx_min][DISTANCE];
        PAIRS[idx_min][DISTANCE] = dconst(10000000);
        i += 1;
    }
}

CIRCUITS; CIRCUITS_CAP; CIRCUIT_COUNT 0;
push_circuit() {
    assert(CIRCUIT_COUNT < CIRCUITS_CAP, "CIRCUITS overflowed");
    auto new_circuit;
    new_circuit = &NUMBERS[NUMBER_COUNT];
    new_circuit[ITEMS] = 0; NUMBER_COUNT++;
    new_circuit[COUNT] = 0; NUMBER_COUNT++;
    new_circuit[CAPACITY] = 0; NUMBER_COUNT++;
    CIRCUITS[CIRCUIT_COUNT++] = new_circuit;
}

circuit_has_box(c, box) {
    auto i, count;
    i = 0; count = c[COUNT];
    while (i < count) {
        if (c[ITEMS][i] == box) return(1);
        i += 1;
    }

    return(0);
}

find_box_circuit(box, res_c) {
    auto i, j;
    i = 0; while (i < CIRCUIT_COUNT) {
        j = 0; while (j < CIRCUITS[i][COUNT]) {
            if (CIRCUITS[i][ITEMS][j] == box) {
                *res_c = CIRCUITS[i];
                return(1);
            }
            j += 1;
        }
        i += 1;
    }

    return(0);
}

find_n_max_circuits(n) {
    auto i, j, idx_max, tmp;
    i = 0; while (i < n) {
        idx_max = i;
        j = i+1; while (j < CIRCUIT_COUNT) {
            if (CIRCUITS[j][COUNT] > CIRCUITS[idx_max][COUNT]) {
                idx_max = j;
            }
            j += 1;
        }

        tmp = CIRCUITS[i];
        CIRCUITS[i] = CIRCUITS[idx_max];
        CIRCUITS[idx_max] = tmp;
        i += 1;
    }
}


main() {
    extrn dprint, malloc;

    WORD_SIZE = &0[1];

    NUMBERS_CAP = 1506000;
    NUMBERS = malloc(NUMBERS_CAP * WORD_SIZE);

    BOXES_CAP = 1000;
    BOXES = malloc(BOXES_CAP * WORD_SIZE);

    CIRCUITS_CAP = 1000;
    CIRCUITS = malloc(CIRCUITS_CAP * WORD_SIZE);

    PAIRS_CAP = 500000;
    PAIRS = malloc(PAIRS_CAP * WORD_SIZE);

    auto N_MIN; N_MIN = 1000;
    load_boxes("input.txt");
    make_pairs();
    find_n_min_distances(N_MIN);

    auto i, j, pair, c1, c2;
    i = 0; while (i < N_MIN) {
        pair = PAIRS[i];
        if (find_box_circuit(pair[A], &c1)) {
            if (find_box_circuit(pair[B], &c2)) {
                if (c1 != c2) {
                    da_append_many(c1, c2[ITEMS], c2[COUNT]);
                    c2[COUNT] = 0;
                }
            } else {
                da_append(c1, pair[B]);
            }
        } else if (find_box_circuit(pair[B], &c2)) {
            da_append(c2, pair[A]);
        } else {
            push_circuit();
            da_append(CIRCUITS[CIRCUIT_COUNT-1], pair[A]);
            da_append(CIRCUITS[CIRCUIT_COUNT-1], pair[B]);
        }

        i += 1;
    }

    auto c;
    find_n_max_circuits(3);
    printf("Answer=%zu\n", CIRCUITS[0][COUNT] * CIRCUITS[1][COUNT] * CIRCUITS[2][COUNT]);
}
