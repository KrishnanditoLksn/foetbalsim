# Panduan Aturan Dasar Sepakbola — Match Engine 2D

Dokumen ini menjadi acuan resmi aturan sepakbola (Laws of the Game modern) dan cara penerapannya di **Match Engine 2D (gaya klasik FM24)** pada proyek **Futbol**.

---

## 1. Aturan Pergantian Pemain (*Substitutions*)

### Aturan Dasar
- **Kuota Maksimal:** Di kompetisi modern (LaLiga & sebagian besar liga top), setiap tim diizinkan melakukan hingga **5 pergantian pemain** dari daftar bangku cadangan (**7 hingga 12 pemain**, tergantung regulasi kompetisi).
- **Batasan Kesempatan (*Stoppages*):** Maksimal **3 kali kesempatan** menghentikan pertandingan untuk melakukan pergantian pemain (bisa memasukkan lebih dari 1 pemain dalam satu *stoppage*).
  - Pergantian saat **jeda babak pertama (*Half-Time*)** **tidak mengurangi** kuota 3 kesempatan ini.
- **Pergantian Gegar Otak (*Concussion Subs*):** Jika pemain mengalami cedera kepala serius di kompetisi yang menerapkan aturan ini, tim mendapat **+1 pergantian tambahan** di luar kuota normal (dan tidak mengurangi batas *stoppage*).
- **Babak Perpanjangan Waktu (*Extra Time*):** Tim mendapat tambahan **+1 pergantian pemain** dan **+1 kesempatan berhenti** (jeda sebelum Extra Time & jeda antar-babak Extra Time tidak mengurangi *stoppage*).

### Penerapan di Match Engine 2D
- Panel **Taktik & Subs** menampilkan sisa kuota: `Subs: X/5` dan `Jendela: Y/3` (plus indikator *Concussion Sub* bila terpicu).
- Pergantian baru efektif saat bola keluar (*ball out of play*) atau pada jeda babak; pemain pengganti masuk dari garis tengah lapangan dan langsung menggantikan titik pemain yang keluar.

---

## 2. Aturan Offside

### Aturan Dasar
- **Deteksi Presisi:** Mesin pertandingan menghitung posisi bagian tubuh pemain yang sah mencetak gol (kepala, badan, kaki) dibandingkan **pemain bertahan kedua terakhir** (biasanya bek terakhir + kiper) serta posisi bola **tepat pada momen umpan dilepaskan**.
- **Offside Pasif:** Pemain yang berada di posisi offside **tidak dianggap melanggar** apabila tidak terlibat aktif dalam permainan (tidak menyentuh bola, tidak mengganggu lawan, dan tidak menghalangi pandangan kiper).
- **Pengecualian (Tanpa Offside):** Tidak berlaku saat:
  - Lemparan ke dalam (*Throw-in*)
  - Tendangan gawang (*Goal kick*)
  - Tendangan sudut (*Corner kick*)
  - Pemain berada di wilayah pertahanannya sendiri saat bola dioper.

### Penerapan di Match Engine 2D
- Saat *event* umpan dilepaskan (`passRelease`), engine mencatat snapshot koordinat `x` bek terakhir dan seluruh pemain menyerang yang melewati garis tersebut (`offsideFlag = true`).
- Pelanggaran offside hanya dibunyikan jika pemain ber-`offsideFlag` menjadi penerima bola, mengejar/mengganggu bek terdekat, atau berada di garis tembak kiper.
- Saat offside terjadi, tampilan 2D memunculkan **garis tipis penanda offside** sesaat + komentar live, lalu permainan dilanjutkan dengan tendangan bebas tidak langsung.

---

## 3. Pelanggaran, Kartu, & Disiplin

### Aturan Dasar
- **Pelanggaran Umum:** Tekel terlambat (*late tackle*), mendorong (*pushing*), menarik baju (*shirt pulling*), hingga menghalangi laju lawan (*obstruction*).
- **Diving (Simulasi):** Pemain dengan kecenderungan nakal (*dirtiness*/agresivitas tertentu) sesekali dapat menjatuhkan diri di kotak penalti. Jika terdeteksi wasit, pemain tersebut diganjar **kartu kuning** dan tendangan bebas untuk lawan.
- **Handball:** Bola yang mengenai tangan/lengan pemain secara tidak wajar menghasilkan tendangan bebas langsung, atau **penalti** jika terjadi di dalam kotak penalti (dapat ditinjau lewat VAR).
- **Akumulasi Kartu & Kartu Merah:**
  - **2 kartu kuning** dalam satu laga = **kartu merah tidak langsung** (pemain keluar, tim bermain dengan 10 pemain).
  - **Kartu merah langsung:** pelanggaran keras (*two-footed / reckless tackle*) atau menggagalkan peluang emas mencetak gol (**DOGSO** — *Denying an Obvious Goal-Scoring Opportunity*).

### Penerapan di Match Engine 2D
- Probabilitas pelanggaran & tingkat keparahannya dihitung dari duel atribut (`tackling`, `aggression`, `decisions` vs `dribbling`, `agility`, `composure`) ditambah kelelahan (`condition`).
- Pemain yang terkena kartu merah langsung dihilangkan dari lapangan 2D, dan formasi tim otomatis menyesuaikan ruang kosongnya (*auto-rebalance anchor*).
- Ikon kartu kuning/merah tampil di samping nama pemain pada papan skor & feed komentar.

---

## 4. Teknologi Wasit (VAR & Garis Gawang)

### Aturan Dasar
- **VAR (*Video Assistant Referee*):** Aktif di liga besar (mis. LALIGA EA SPORTS) dan turnamen besar. Digunakan untuk meninjau **4 skenario krusial**:
  1. **Keabsahan Gol** (indikasi offside tipis atau pelanggaran dalam *build-up* sebelum gol).
  2. **Keputusan Penalti** (pelanggaran di garis/kotak penalti, *handball*, atau *diving*).
  3. **Kartu Merah Langsung** (apakah pelanggaran layak merah langsung atau cukup kuning).
  4. **Kesalahan Identitas** (*mistaken identity*) pemain yang diberi kartu.
- **Teknologi Garis Gawang (*Goal-Line Technology* / GLT):** Secara otomatis dan instan memastikan apakah seluruh lingkaran bola sudah melewati garis gawang sepenuhnya atau belum, terutama pada situasi kemelut/tepis kiper di garis.

### Penerapan di Match Engine 2D
- **Visual VAR di 2D:** Saat pengecekan VAR dipicu, permainan berhenti sejenak, muncul banner `PENINJAUAN VAR...`, dan **ikon wasit di layar 2D terlihat berlari menuju monitor di garis tepi lapangan** (*pitchside monitor*) sebelum keputusan final (Gol Sah / Dianulir / Penalti / Kartu Merah) diumumkan di komentar live.
- **Visual GLT:** Pada tembakan yang mengenai mistar/tiang atau ditepis di garis gawang (jarak < 0,3m dari garis), muncul notifikasi singkat `GOAL-LINE TECH: GOL / BELUM MELEWATI GARIS` di komentar live.

---

## 5. Aturan Bola Mati (*Set Pieces*) & Kiper

### Aturan Dasar
- **Aturan 6 Detik Kiper:** Kiper tidak boleh menahan bola dengan tangan terlalu lama di kotak penalti. Jika membuang waktu berlebihan (sangat jarang, tapi mungkin terjadi), wasit dapat menghukum dengan **tendangan bebas tidak langsung** di dalam kotak penalti.
- **Aturan Backpass:** Kiper dilarang menangkap bola dengan tangan jika bola sengaja dioper menggunakan kaki oleh rekan setimnya (atau dari lemparan ke dalam rekan setim). Pelanggaran berbuah tendangan bebas tidak langsung.
- **Tendangan Penalti:**
  - Bola ditempatkan di titik penalti (`11m` dari garis gawang); seluruh pemain selain penendang dan kiper berada di luar kotak penalti & busur penalti.
  - Kiper **wajib menempatkan minimal satu kaki di garis gawang** saat bola ditendang. Jika kiper maju lebih dulu (*encroachment*) dan menepis bola, penalti **diulang** (dan kiper bisa mendapat peringatan/kartu kuning).
- **Bola Mati Lainnya:** Tendangan bebas langsung/tidak langsung, sepak pojok (*corner*), lemparan ke dalam (*throw-in*), tendangan gawang (*goal kick*), dan *kick-off* (awal babak & setelah gol).

### Penerapan di Match Engine 2D
- Engine memiliki *sub-state* khusus untuk setiap set piece (`kickOff`, `throwIn`, `goalKick`, `corner`, `freeKick`, `penalty`) di mana posisi 22 pemain otomatis tertata sesuai skema bola mati sebelum bola dieksekusi.
- Pada tendangan penalti, duel dihitung dari `finishing` + `composure` + `technique` penendang melawan `reflexes` + `oneOnOnes` + `positioning` kiper, disertai cek kecil kemungkinan kiper keluar garis lebih awal.

---

## 6. Waktu Pertandingan & Penentuan Pemenang

### Aturan Dasar
- **Waktu Normal:** 2 × 45 menit (babak pertama `0'–45'`, jeda *Half-Time*, babak kedua `45'–90'`).
- **Injury Time (Tambahan Waktu):** Dihitung secara **dinamis** dari akumulasi waktu terbuang di tiap babak akibat:
  - Cedera & perawatan pemain
  - Pergantian pemain (*substitutions*)
  - Selebrasi gol
  - Pengecekan VAR & pembuangan waktu (*time-wasting*)
- **Babak Gugur (*Knockout* / Playoff):**
  - Jika skor masih imbang hingga waktu normal berakhir → dilanjutkan ke **Perpanjangan Waktu (*Extra Time*) 2 × 15 menit** (+ tambahan 1 sub & 1 *stoppage*).
  - Jika masih imbang setelah 120 menit → dilanjutkan ke **Adu Penalti (*Penalty Shootout*)**: 5 penendang pertama per tim, lalu *sudden death* (1 lawan 1) hingga ada pemenang.

### Penerapan di Match Engine 2D
- Jam pertandingan menampilkan `45+X'` dan `90+Y'` berdasarkan akumulator detik terbuang (`stoppageSeconds`) yang dicatat engine selama babak berjalan; wasit tidak meniup peluit akhir tepat saat bola sedang dalam situasi serangan berbahaya di kotak penalti (*advantage finish*).
- Untuk laga liga reguler (LaLiga EA SPORTS & LALIGA HYPERMOTION), pertandingan berakhir di `90+Y'`. Flag `allowExtraTimeAndPenalties` disiapkan di konfigurasi match agar langsung siap dipakai untuk laga playoff promosi atau piala di fase mendatang.

---

## Ringkasan Regulasi Default di Proyek Futbol

| Parameter | Liga Reguler (LaLiga / Hypermotion) | Babak Gugur / Playoff |
|---|---|---|
| **Maks. Pergantian** | 5 pemain (dari 7 cadangan) | 5 (+1 di Extra Time) |
| **Maks. Kesempatan Berhenti** | 3 (tidak termasuk Half-Time) | 3 (+1 di Extra Time) |
| **Concussion Sub** | +1 (jika cedera kepala serius) | +1 (jika cedera kepala serius) |
| **Offside & Set Pieces** | Penuh (termasuk offside pasif) | Penuh |
| **VAR & Goal-Line Tech** | Aktif (LaLiga EA SPORTS) | Aktif |
| **Waktu Tambahan** | Dinamis per babak | Dinamis + Extra Time (2×15') + Adu Penalti |
