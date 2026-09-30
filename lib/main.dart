import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

// Model data mahasiswa
class Mahasiswa {
  final String nim;
  final String nama;
  final String prodi;
  final String kelas;

  Mahasiswa({
    required this.nim,
    required this.nama,
    required this.prodi,
    required this.kelas,
  });
}

// Aksi dari halaman detail: edit atau hapus
enum AksiDetail { edit, hapus }

class HasilDetail {
  final AksiDetail aksi;
  final Mahasiswa? dataBaru; // dipakai jika aksi = edit

  HasilDetail(this.aksi, {this.dataBaru});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Data Mahasiswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const DataMahasiswaPage(),
    );
  }
}

// ===================== TAHAP 1: HALAMAN DAFTAR =====================
class DataMahasiswaPage extends StatefulWidget {
  const DataMahasiswaPage({super.key});

  @override
  State<DataMahasiswaPage> createState() => _DataMahasiswaPageState();
}

class _DataMahasiswaPageState extends State<DataMahasiswaPage> {
  // Data sementara menggunakan List
  final List<Mahasiswa> _dataMahasiswa = [
    Mahasiswa(
        nim: '25781052',
        nama: 'Ziyan Ramadhan',
        prodi: 'Manajemen Informatika',
        kelas: '3B'),
    Mahasiswa(
        nim: '25781034',
        nama: 'Ghifari Azhar',
        prodi: 'Manajemen Informatika',
        kelas: '3B'),
    Mahasiswa(
        nim: '25781046',
        nama: 'Reyhan Prastyawan',
        prodi: 'Manajemen Informatika',
        kelas: '3B'),
    Mahasiswa(
        nim: '25781047',
        nama: 'Risqi Laila',
        prodi: 'Manajemen Informatika',
        kelas: '3B'),
    Mahasiswa(
        nim: '25781027',
        nama: 'Ahmad Anwarul Iman',
        prodi: 'Manajemen Informatika',
        kelas: '3B'),
  ];

  // ===================== TAHAP 7: PENCARIAN =====================
  final TextEditingController _searchController = TextEditingController();
  String _keyword = '';

  // ===================== TANTANGAN 1: FILTER PROGRAM STUDI =====================
  final List<String> _pilihanProdi = [
    'Semua',
    'Informatika',
    'Sistem Informasi',
    'Teknik Komputer',
  ];
  String _filterProdi = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Daftar yang ditampilkan: cocok dengan pencarian DAN filter program studi
  List<Mahasiswa> get _hasilPencarian {
    final kata = _keyword.toLowerCase();
    return _dataMahasiswa.where((m) {
      final cocokCari = m.nama.toLowerCase().contains(kata) ||
          m.nim.toLowerCase().contains(kata);
      final cocokProdi = _filterProdi == 'Semua' ||
          m.prodi.toLowerCase().contains(_filterProdi.toLowerCase());
      return cocokCari && cocokProdi;
    }).toList();
  }

  // ===================== TAHAP 2: BUKA FORM TAMBAH =====================
  Future<void> _tambahMahasiswa() async {
    // Buka halaman form, tunggu data yang dikembalikan saat Simpan
    final hasil = await Navigator.push<Mahasiswa>(
      context,
      MaterialPageRoute(builder: (_) => const FormMahasiswaPage()),
    );

    // Jika ada data baru, masukkan ke list dan refresh tampilan
    if (hasil != null) {
      setState(() {
        _dataMahasiswa.add(hasil);
      });
    }
  }

  // ===================== TAHAP 4: PINDAH KE HALAMAN DETAIL =====================
  Future<void> _bukaDetail(Mahasiswa m) async {
    // Halaman detail mengembalikan aksi: edit (bawa data baru) atau hapus
    final hasil = await Navigator.push<HasilDetail>(
      context,
      MaterialPageRoute(builder: (_) => DetailMahasiswaPage(mahasiswa: m)),
    );

    if (hasil == null) return;

    final index = _dataMahasiswa.indexOf(m);
    if (index == -1) return;

    setState(() {
      if (hasil.aksi == AksiDetail.edit && hasil.dataBaru != null) {
        // TAHAP 5: update data di list
        _dataMahasiswa[index] = hasil.dataBaru!;
      } else if (hasil.aksi == AksiDetail.hapus) {
        // TAHAP 6: keluarkan data dari list
        _dataMahasiswa.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tampil = _hasilPencarian;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Mahasiswa'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // Tombol + Tambah Mahasiswa di kanan bawah
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambahMahasiswa,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Mahasiswa'),
      ),
      body: Column(
        children: [
          // Kolom pencarian
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Cari nama atau NIM...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                // Tombol X untuk menghapus teks pencarian
                suffixIcon: _keyword.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _keyword = '');
                        },
                      ),
              ),
              // Setiap ketikan memperbarui daftar
              onChanged: (value) {
                setState(() => _keyword = value.trim());
              },
            ),
          ),
          // Tantangan 1: bar filter program studi (dropdown)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Program Studi',
                prefixIcon: const Icon(Icons.filter_list),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _filterProdi,
                  isExpanded: true,
                  items: _pilihanProdi.map((prodi) {
                    return DropdownMenuItem<String>(
                      value: prodi,
                      child: Text(prodi),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _filterProdi = value);
                    }
                  },
                ),
              ),
            ),
          ),
          // Tantangan 2: jumlah mahasiswa (ikut berubah saat tambah/hapus)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Total Mahasiswa: ${_dataMahasiswa.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            // Tantangan 3: empty state jika semua data dihapus
            child: _dataMahasiswa.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada data mahasiswa',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : tampil.isEmpty
                ? const Center(child: Text('Data tidak ditemukan'))
                : ListView.builder(
        // padding bawah supaya data terakhir tidak tertutup tombol
        padding: const EdgeInsets.only(bottom: 88),
        itemCount: tampil.length,
        itemBuilder: (context, index) {
          final m = tampil[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _bukaDetail(m),
              child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kolom kiri: NIM
                  SizedBox(
                    width: 90,
                    child: Text(
                      m.nim,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  // Kolom kanan: Nama, Program Studi, Kelas
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.nama,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(m.prodi),
                        Text(m.kelas),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ),
          );
        },
      ),
          ),
        ],
      ),
    );
  }
}

// ===================== TAHAP 4: HALAMAN DETAIL MAHASISWA =====================
class DetailMahasiswaPage extends StatelessWidget {
  final Mahasiswa mahasiswa;

  const DetailMahasiswaPage({super.key, required this.mahasiswa});

  // Satu blok: label kecil abu-abu + nilai di bawahnya
  Widget _item(String label, String nilai) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(nilai, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  // ===================== TAHAP 6: TOMBOL HAPUS + DIALOG KONFIRMASI =====================
  Future<void> _hapus(BuildContext context) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus data ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    // Jika memilih Hapus, kembali ke daftar dan minta data dihapus
    if (yakin == true && context.mounted) {
      Navigator.pop(context, HasilDetail(AksiDetail.hapus));
    }
  }

  // ===================== TAHAP 5: TOMBOL EDIT =====================
  Future<void> _edit(BuildContext context) async {
    // Buka form edit dengan membawa data lama
    final hasil = await Navigator.push<Mahasiswa>(
      context,
      MaterialPageRoute(
        builder: (_) => FormMahasiswaPage(mahasiswa: mahasiswa),
      ),
    );

    // Jika disimpan, kembali ke daftar sambil membawa data yang sudah diubah
    if (hasil != null && context.mounted) {
      Navigator.pop(context, HasilDetail(AksiDetail.edit, dataBaru: hasil));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Mahasiswa'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _item('NIM', mahasiswa.nim),
                      _item('Nama', mahasiswa.nama),
                      _item('Program Studi', mahasiswa.prodi),
                      _item('Kelas', mahasiswa.kelas),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _edit(context),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _hapus(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.delete),
                    label: const Text('Hapus'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== TAHAP 2, 3, 5: FORM TAMBAH & EDIT + VALIDASI =====================
class FormMahasiswaPage extends StatefulWidget {
  // null = mode tambah, berisi data = mode edit
  final Mahasiswa? mahasiswa;

  const FormMahasiswaPage({super.key, this.mahasiswa});

  @override
  State<FormMahasiswaPage> createState() => _FormMahasiswaPageState();
}

class _FormMahasiswaPageState extends State<FormMahasiswaPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nimController;
  late final TextEditingController _namaController;
  late final TextEditingController _prodiController;
  late final TextEditingController _kelasController;

  bool get _modeEdit => widget.mahasiswa != null;

  @override
  void initState() {
    super.initState();
    // Mode edit: data lama otomatis muncul di form
    _nimController = TextEditingController(text: widget.mahasiswa?.nim ?? '');
    _namaController =
        TextEditingController(text: widget.mahasiswa?.nama ?? '');
    _prodiController =
        TextEditingController(text: widget.mahasiswa?.prodi ?? '');
    _kelasController =
        TextEditingController(text: widget.mahasiswa?.kelas ?? '');
  }

  @override
  void dispose() {
    _nimController.dispose();
    _namaController.dispose();
    _prodiController.dispose();
    _kelasController.dispose();
    super.dispose();
  }

  void _simpan() {
    // Tahap 3: lanjut hanya jika semua field lolos validasi
    if (_formKey.currentState!.validate()) {
      final mahasiswaBaru = Mahasiswa(
        nim: _nimController.text.trim(),
        nama: _namaController.text.trim(),
        prodi: _prodiController.text.trim(),
        kelas: _kelasController.text.trim(),
      );
      // Kembali ke daftar sambil membawa data baru
      Navigator.pop(context, mahasiswaBaru);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modeEdit ? 'Edit Mahasiswa' : 'Tambah Mahasiswa'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nimController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'NIM',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'NIM wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _prodiController,
                decoration: const InputDecoration(
                  labelText: 'Program Studi',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Program Studi wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _kelasController,
                decoration: const InputDecoration(
                  labelText: 'Kelas',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Kelas wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _simpan,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(_modeEdit ? 'Simpan Perubahan' : 'Simpan'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}