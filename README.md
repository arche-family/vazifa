# vazifa

Terminal uchun vazifalar ro'yxati, [Arche](https://github.com/arche-family/arche-lang) tilida yozilgan. Tilning o'zi qanday ko'rinishini va o'rta hajmdagi dastur unda qanday tuzilishini ko'rsatish uchun yozilgan misol.

## Build va testlar

Avval `arche-lang` compiler'i build qilingan bo'lishi kerak (`make -C stage0 && make -C compiler`), [`27acafe`](https://github.com/arche-family/arche-lang/commit/27acafe) yoki undan yangisi: bu yerda `catch return`, `orelse return`, `f(today:)` va `alloc.String.from` ishlatiladi. Build uchun clang va `ARCHE_HOME` kerak; u berilmasa `~/Desktop/arche/arche-lang` olinadi.

```sh
./build.sh          # build/vazifa
./build.sh test     # har modulning test bloklari
```

LLVM'siz, compiler'ning o'z backend va linker'i bilan:

```sh
ARCHE_BACKEND=own ./build.sh
```

## Ishlatish

```sh
vazifa qosh Oylik hisobotni yozish -m yuqori -d 2026-11-10 -t ish
vazifa qosh Non olish -t uy
vazifa qosh -m past -- -5 kg kartoshka
vazifa royxat
vazifa royxat -a --format csv
vazifa royxat -t ish -q hisobot
vazifa royxat --kechikkan
vazifa bajar 2
vazifa qaytar 2
vazifa ochir 2
vazifa statistika
```

```text
    1 [ ] yuqori 2026-11-10 (4 kun)          Oylik hisobotni yozish #ish
    3 [ ] oddiy  2026-10-01 (36 kun o'tdi)   Eski ish #ish
    2 [ ] oddiy                              Non olish #uy
3 ta vazifa, 1 tasi kechikkan
```

Vazifalar JSON faylda saqlanadi: `--fayl <yo'l>`, `VAZIFA_FAYL` muhit o'zgaruvchisi yoki joriy papkadagi `vazifalar.json`. Xato bo'lsa dastur sababini aytadi va 1 bilan (buyruq noto'g'ri bo'lsa 2 bilan) tugaydi.

- **Saqlash:** yangi matn tasodifiy nomli faylga yoziladi, diskka `sync` qilinadi, o'z joyiga `rename` qilinadi va papka ham `sync` qilinadi. Shuning uchun na dastur yiqilishi, na tok o'chishi yarim faylni qoldirmaydi.
- **Bir vaqtda ishlash:** ikki nusxa bir vaqtda yozsa, fayl buzilmaydi, lekin oxirgi yozgani qoladi: fayl bloklanmaydi, chunki `std.Fs`da hali qulf yo'q.
- **Fayl tekshiruvi:** fayldagi takroriy vazifa raqami xato deb aytiladi.
- **Qidiruv (`-q`):** lotin harflarining katta-kichikligiga va o'zbekchadagi apostrof turlariga (`ʻ ’ ‘ ʼ ' `) qaramaydi.
- **Sana:** "bugun" Toshkent vaqti bilan (UTC+5) hisoblanadi. Bu `date.arche`da yozilgan, chunki tilda hali vaqt zonasi yo'q.

## Tuzilishi

| Fayl | Vazifasi | Unga nima kerak |
| --- | --- | --- |
| `main.arche` | buyruqni bajaradi; `std.System`ni faqat shu fayl ushlaydi | hamma capability |
| `cli.arche` | buyruq qatorini `Command`ga aylantiradi | hech narsa |
| `board.arche` | vazifalar, ularning holati va tartibi | hech narsa |
| `date.arche` | sanalar: tekshirish, farq, bugungi kun | `today` uchun `Clock` |
| `store.arche` | JSON fayl: tasodifiy nomli vaqtinchalik fayl, `sync`, rename | `Fs`, `Rand` |
| `report.arche` | jadval, CSV va statistika | `Output` |

## Bu yerda ko'rinadigan til xususiyatlari

- **Imzo to'liq shartnoma.** `store.load(fs, path, a)` fayl tizimini oladi, soatni emas; `board.arche` hech qanday I/O qila olmaydi. `package.arche`dagi `needs` esa butun paket nimaga kira olishini aytadi.
- **Xatolar qiymat.** Har modulning o'z `error` to'plami bor (`CliError`, `BoardError`, `StoreError`), ular `try`, `match` va bir qatorli `x catch return y` bilan o'tadi, exception yo'q.
- **Payload'li `enum`.** `Command.Add { title, tags, priority, due }`, `Status.Done { on }`.
- **Interfeys.** `report.Report`ni `Table` va `Csv` bajaradi, `&mut dyn Report` orqali chaqiriladi; `Rank` esa `core.Ord`ni bajarib `core.slice.sort`ga tushadi.
- **Generic va closure.** `board.count_where(comptime T, items, test_item)` har qanday element uchun ishlaydi, `Board.select` esa `&dyn fn(&Task) -> bool` oladi.
- **Handle'lar.** Vazifaga uzoq muddatli havola ko'rsatkich emas, raqam (`id`) orqali; list ichidagi joyi `u32`. View'lar faqat parametr va lokal o'zgaruvchi bo'la oladi.
- **Determinizm.** Bir xil vazifalar bir xil baytlarga yoziladi; `store.arche`dagi test buni tekshiradi.
- **`match` ifoda sifatida.** `let x = match ... { ok(v) => { v } err(e) => { ...; return ...; } };`, `is_open` esa bitta `match` ifodasi.
- **Label qisqartmasi.** `b.add(title, tags, priority, due:, created: today)`: `due:` yolg'iz o'zi `due: due` degani.
