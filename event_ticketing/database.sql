-- ============================================================
--  TIKETKU — Event Ticketing Database
--  
--  CARA PAKAI:
--  1. Buka phpMyAdmin (localhost/phpmyadmin)
--  2. Klik "New" untuk buat database baru
--  3. Klik tab "SQL"
--  4. Copy paste SEMUA isi file ini
--  5. Klik "Go"
-- ============================================================

CREATE DATABASE IF NOT EXISTS event_ticketing
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE event_ticketing;

-- ============================================================
--  TABEL TANPA FOREIGN KEY
-- ============================================================

-- Tabel organizers
CREATE TABLE IF NOT EXISTS organizers (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    contact_email VARCHAR(100),
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabel users
CREATE TABLE IF NOT EXISTS users (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(100) NOT NULL,
    email      VARCHAR(100) UNIQUE NOT NULL,
    phone      VARCHAR(20),
    password   VARCHAR(255) NOT NULL DEFAULT '',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
--  TABEL DENGAN FOREIGN KEY
-- ============================================================

-- Tabel events (FK → organizers)
CREATE TABLE IF NOT EXISTS events (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(150) NOT NULL,
    event_date      DATETIME NOT NULL,
    venue           VARCHAR(200),
    description     TEXT,
    image_url       VARCHAR(500),
    location_detail VARCHAR(300),
    capacity        INT DEFAULT 0,
    price           DECIMAL(10,2) DEFAULT 0,
    organizer_id    INT NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (organizer_id) REFERENCES organizers(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabel tickets (FK → events, users)
-- ticket_code mendukung custom prefix: PREFIX-YYYYMMDD-XXXX
CREATE TABLE IF NOT EXISTS tickets (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    ticket_code   VARCHAR(50) UNIQUE NOT NULL,
    purchase_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status        ENUM('pending','confirmed','cancelled') DEFAULT 'pending',
    qty           INT DEFAULT 1,
    event_id      INT NOT NULL,
    user_id       INT NOT NULL,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id)  REFERENCES users(id)  ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabel payments (FK → tickets)
CREATE TABLE IF NOT EXISTS payments (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    amount       DECIMAL(10,2) NOT NULL,
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    method       ENUM('transfer','cash','card') DEFAULT 'transfer',
    status       ENUM('unpaid','paid','failed') DEFAULT 'unpaid',
    ticket_id    INT NOT NULL UNIQUE,
    FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabel ticket_categories (FK → events)
CREATE TABLE IF NOT EXISTS ticket_categories (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    event_id   INT NOT NULL,
    name       VARCHAR(100) NOT NULL,
    price      DECIMAL(10,2) NOT NULL,
    quota      INT DEFAULT 0,
    sold       INT DEFAULT 0,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
--  DATA AWAL (DUMMY DATA)
-- ============================================================

-- Organizers
INSERT INTO organizers (name, contact_email) VALUES
('Himpunan Mahasiswa Ilmu Komputer', 'himakom@univ.edu'),
('Unit Kegiatan Mahasiswa Seni',     'ukm_seni@univ.edu'),
('BEM Fakultas Teknik',              'bemft@univ.edu');

-- Users
-- Password login sama dengan kolom password di bawah (plaintext untuk demo)
-- Akun admin: admin@tiketku.com / admin123
-- Akun user:  budi@example.com  / budi123
--             siti@example.com  / siti123
--             rizky@example.com / rizky123
INSERT INTO users (name, email, phone, password) VALUES
('Administrator', 'admin@tiketku.com', '000000000000', 'admin123'),
('Budi Santoso',  'budi@example.com',  '081234567890', 'budi123'),
('Siti Aminah',   'siti@example.com',  '089876543210', 'siti123'),
('Rizky Pratama', 'rizky@example.com', '082345678901', 'rizky123');

-- Events
INSERT INTO events (name, event_date, venue, description, image_url, location_detail, capacity, price, organizer_id) VALUES
(
    'Tech Conference 2026',
    '2026-08-15 09:00:00',
    'Auditorium Utama',
    'Sebuah acara seminar nasional yang menghadirkan para pakar teknologi informasi dan kecerdasan buatan dari seluruh Indonesia. Diskusi mendalam tentang masa depan AI, machine learning, dan dampaknya terhadap industri.',
    'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800&q=80',
    'Auditorium Utama, Gedung A Lt. 2, Universitas Contoh, Jl. Pendidikan No. 1',
    100,
    50000.00,
    1
),
(
    'Pentas Seni Tahunan',
    '2026-10-20 18:00:00',
    'Lapangan Terbuka',
    'Pentas seni tahunan yang menampilkan berbagai pertunjukan seni budaya mahasiswa, mulai dari tari tradisional, musik kontemporer, teater, hingga pameran karya seni rupa.',
    'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800&q=80',
    'Lapangan Terbuka Kampus, Area Parkir Barat, Universitas Contoh',
    200,
    35000.00,
    2
),
(
    'Workshop UI/UX Design',
    '2026-07-05 10:00:00',
    'Lab Komputer Lt. 3',
    'Workshop intensif selama satu hari penuh tentang desain antarmuka dan pengalaman pengguna. Peserta akan belajar langsung menggunakan Figma, prinsip desain modern, dan studi kasus nyata.',
    'https://images.unsplash.com/photo-1558655146-d09347e92766?w=800&q=80',
    'Lab Komputer Lt. 3, Gedung Teknik, Universitas Contoh',
    40,
    75000.00,
    1
),
(
    'Malam Keakraban Mahasiswa',
    '2026-09-01 19:00:00',
    'Gedung Serbaguna',
    'Malam keakraban mahasiswa baru bersama seluruh civitas akademika. Acara penuh kegembiraan dengan games, penampilan bakat, dan makan malam bersama.',
    'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800&q=80',
    'Gedung Serbaguna Lt. 1, Universitas Contoh',
    300,
    25000.00,
    3
);

-- Ticket Categories
INSERT INTO ticket_categories (event_id, name, price, quota, sold) VALUES
-- Tech Conference 2026 (event_id = 1)
(1, 'Early Bird',    35000.00, 30,  30),
(1, 'Regular',       50000.00, 50,  20),
(1, 'VIP',          100000.00, 20,   5),

-- Pentas Seni Tahunan (event_id = 2)
(2, 'Umum',          35000.00, 150, 80),
(2, 'Tribun',        50000.00,  30, 10),
(2, 'VVIP',          75000.00,  20,  3),

-- Workshop UI/UX Design (event_id = 3)
(3, 'Peserta',       75000.00,  30, 15),
(3, 'Peserta + Kit', 95000.00,  10,  4),

-- Malam Keakraban (event_id = 4)
(4, 'Reguler',       25000.00, 200, 50),
(4, 'All-in',        40000.00,  50, 10);