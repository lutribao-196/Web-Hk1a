-- =========================================================
-- CSDL WEBSITE BAN TRA SUA
-- MySQL 8.x
-- Dat ten bang/cot bang TIENG VIET KHONG DAU de de dung va tranh loi.
-- =========================================================

CREATE DATABASE IF NOT EXISTS web_ban_tra_sua
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE web_ban_tra_sua;

-- 1. NGUOI DUNG: Khach hang + Quan tri vien
CREATE TABLE nguoi_dung (
    ma_nguoi_dung BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ho_ten VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    so_dien_thoai VARCHAR(20),
    mat_khau VARCHAR(255) NOT NULL,
    dia_chi VARCHAR(255),
    vai_tro ENUM('KHACH_HANG', 'QUAN_TRI') NOT NULL DEFAULT 'KHACH_HANG',
    trang_thai ENUM('HOAT_DONG', 'KHOA') NOT NULL DEFAULT 'HOAT_DONG',
    ngay_tao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngay_cap_nhat DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. DANH MUC
CREATE TABLE danh_muc (
    ma_danh_muc BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ten_danh_muc VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(120) NOT NULL UNIQUE,
    mo_ta VARCHAR(500),
    trang_thai ENUM('HOAT_DONG', 'NGUNG') NOT NULL DEFAULT 'HOAT_DONG',
    ngay_tao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngay_cap_nhat DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 3. SAN PHAM
CREATE TABLE san_pham (
    ma_san_pham BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ma_danh_muc BIGINT UNSIGNED NOT NULL,
    ten_san_pham VARCHAR(150) NOT NULL,
    slug VARCHAR(180) NOT NULL UNIQUE,
    mo_ta TEXT,
    hinh_anh VARCHAR(500),
    gia_co_ban DECIMAL(12,2) NOT NULL DEFAULT 0,
    trang_thai ENUM('HOAT_DONG', 'NGUNG_BAN', 'HET_HANG') NOT NULL DEFAULT 'HOAT_DONG',
    ngay_tao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngay_cap_nhat DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_san_pham_danh_muc
        FOREIGN KEY (ma_danh_muc)
        REFERENCES danh_muc(ma_danh_muc)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    INDEX idx_san_pham_danh_muc (ma_danh_muc),
    INDEX idx_san_pham_ten (ten_san_pham),
    INDEX idx_san_pham_trang_thai (trang_thai)
) ENGINE=InnoDB;

-- 4. KICH THUOC SAN PHAM
CREATE TABLE kich_thuoc_san_pham (
    ma_kich_thuoc BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ma_san_pham BIGINT UNSIGNED NOT NULL,
    ten_kich_thuoc VARCHAR(20) NOT NULL,
    gia_them DECIMAL(12,2) NOT NULL DEFAULT 0,
    trang_thai ENUM('HOAT_DONG', 'NGUNG') NOT NULL DEFAULT 'HOAT_DONG',

    CONSTRAINT fk_kich_thuoc_san_pham
        FOREIGN KEY (ma_san_pham)
        REFERENCES san_pham(ma_san_pham)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT uq_san_pham_kich_thuoc UNIQUE (ma_san_pham, ten_kich_thuoc),
    INDEX idx_kich_thuoc_ma_san_pham (ma_san_pham)
) ENGINE=InnoDB;

-- 5. GIO HANG
CREATE TABLE gio_hang (
    ma_gio_hang BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ma_nguoi_dung BIGINT UNSIGNED NOT NULL UNIQUE,
    ngay_tao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngay_cap_nhat DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_gio_hang_nguoi_dung
        FOREIGN KEY (ma_nguoi_dung)
        REFERENCES nguoi_dung(ma_nguoi_dung)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- 6. CHI TIET GIO HANG
CREATE TABLE chi_tiet_gio_hang (
    ma_ct_gio_hang BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ma_gio_hang BIGINT UNSIGNED NOT NULL,
    ma_san_pham BIGINT UNSIGNED NOT NULL,
    ma_kich_thuoc BIGINT UNSIGNED NULL,
    so_luong INT UNSIGNED NOT NULL DEFAULT 1,
    don_gia DECIMAL(12,2) NOT NULL,
    ngay_tao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_ct_gio_hang_gio_hang
        FOREIGN KEY (ma_gio_hang)
        REFERENCES gio_hang(ma_gio_hang)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_ct_gio_hang_san_pham
        FOREIGN KEY (ma_san_pham)
        REFERENCES san_pham(ma_san_pham)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_ct_gio_hang_kich_thuoc
        FOREIGN KEY (ma_kich_thuoc)
        REFERENCES kich_thuoc_san_pham(ma_kich_thuoc)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    INDEX idx_ct_gio_hang_gio_hang (ma_gio_hang),
    INDEX idx_ct_gio_hang_san_pham (ma_san_pham)
) ENGINE=InnoDB;

-- 7. TOPPING THEM TRONG GIO HANG
CREATE TABLE topping_gio_hang (
    ma_topping_gio_hang BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ma_ct_gio_hang BIGINT UNSIGNED NOT NULL,
    ma_san_pham_topping BIGINT UNSIGNED NOT NULL,
    so_luong INT UNSIGNED NOT NULL DEFAULT 1,
    don_gia DECIMAL(12,2) NOT NULL,

    CONSTRAINT fk_topping_gio_hang_ct_gio_hang
        FOREIGN KEY (ma_ct_gio_hang)
        REFERENCES chi_tiet_gio_hang(ma_ct_gio_hang)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_topping_gio_hang_san_pham
        FOREIGN KEY (ma_san_pham_topping)
        REFERENCES san_pham(ma_san_pham)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT uq_topping_gio_hang UNIQUE (ma_ct_gio_hang, ma_san_pham_topping),

    INDEX idx_topping_gio_hang_ct (ma_ct_gio_hang)
) ENGINE=InnoDB;

-- 8. DON HANG
CREATE TABLE don_hang (
    ma_don_hang BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ma_don VARCHAR(30) NOT NULL UNIQUE,
    ma_nguoi_dung BIGINT UNSIGNED NOT NULL,

    ten_nguoi_nhan VARCHAR(100) NOT NULL,
    sdt_nguoi_nhan VARCHAR(20) NOT NULL,
    dia_chi_giao_hang VARCHAR(255) NOT NULL,
    ghi_chu VARCHAR(500),

    tam_tinh DECIMAL(12,2) NOT NULL DEFAULT 0,
    phi_giao_hang DECIMAL(12,2) NOT NULL DEFAULT 0,
    giam_gia DECIMAL(12,2) NOT NULL DEFAULT 0,
    tong_tien DECIMAL(12,2) NOT NULL DEFAULT 0,

    phuong_thuc_thanh_toan ENUM('COD', 'CHUYEN_KHOAN') NOT NULL DEFAULT 'COD',
    trang_thai_thanh_toan ENUM('CHUA_THANH_TOAN', 'DA_THANH_TOAN', 'HOAN_TIEN') NOT NULL DEFAULT 'CHUA_THANH_TOAN',

    trang_thai_don_hang ENUM(
        'CHO_XAC_NHAN',
        'DA_XAC_NHAN',
        'DANG_CHUAN_BI',
        'DANG_GIAO',
        'DA_GIAO',
        'DA_HUY'
    ) NOT NULL DEFAULT 'CHO_XAC_NHAN',

    ngay_tao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngay_cap_nhat DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_don_hang_nguoi_dung
        FOREIGN KEY (ma_nguoi_dung)
        REFERENCES nguoi_dung(ma_nguoi_dung)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    INDEX idx_don_hang_nguoi_dung (ma_nguoi_dung),
    INDEX idx_don_hang_trang_thai (trang_thai_don_hang),
    INDEX idx_don_hang_ngay_tao (ngay_tao)
) ENGINE=InnoDB;

-- 9. CHI TIET DON HANG
CREATE TABLE chi_tiet_don_hang (
    ma_ct_don_hang BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ma_don_hang BIGINT UNSIGNED NOT NULL,
    ma_san_pham BIGINT UNSIGNED NULL,

    ten_san_pham VARCHAR(150) NOT NULL,
    ten_kich_thuoc VARCHAR(20),
    so_luong INT UNSIGNED NOT NULL DEFAULT 1,
    don_gia DECIMAL(12,2) NOT NULL,
    thanh_tien DECIMAL(12,2) NOT NULL,

    CONSTRAINT fk_ct_don_hang_don_hang
        FOREIGN KEY (ma_don_hang)
        REFERENCES don_hang(ma_don_hang)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_ct_don_hang_san_pham
        FOREIGN KEY (ma_san_pham)
        REFERENCES san_pham(ma_san_pham)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    INDEX idx_ct_don_hang_ma_don (ma_don_hang)
) ENGINE=InnoDB;

-- 10. TOPPING CUA TUNG MON TRONG DON HANG
CREATE TABLE topping_don_hang (
    ma_topping_don_hang BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ma_ct_don_hang BIGINT UNSIGNED NOT NULL,
    ma_san_pham_topping BIGINT UNSIGNED NULL,

    ten_topping VARCHAR(150) NOT NULL,
    so_luong INT UNSIGNED NOT NULL DEFAULT 1,
    don_gia DECIMAL(12,2) NOT NULL,
    thanh_tien DECIMAL(12,2) NOT NULL,

    CONSTRAINT fk_topping_don_hang_ct_don
        FOREIGN KEY (ma_ct_don_hang)
        REFERENCES chi_tiet_don_hang(ma_ct_don_hang)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_topping_don_hang_san_pham
        FOREIGN KEY (ma_san_pham_topping)
        REFERENCES san_pham(ma_san_pham)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    INDEX idx_topping_don_hang_ct (ma_ct_don_hang)
) ENGINE=InnoDB;

-- 11. YEU CAU HO TRO
CREATE TABLE yeu_cau_ho_tro (
    ma_yeu_cau BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ma_nguoi_dung BIGINT UNSIGNED NOT NULL,
    tieu_de VARCHAR(200) NOT NULL,
    noi_dung TEXT NOT NULL,
    trang_thai ENUM('MOI', 'DA_PHAN_HOI', 'DA_DONG') NOT NULL DEFAULT 'MOI',
    ngay_tao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngay_cap_nhat DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_yeu_cau_ho_tro_nguoi_dung
        FOREIGN KEY (ma_nguoi_dung)
        REFERENCES nguoi_dung(ma_nguoi_dung)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    INDEX idx_yeu_cau_ho_tro_nguoi_dung (ma_nguoi_dung),
    INDEX idx_yeu_cau_ho_tro_trang_thai (trang_thai)
) ENGINE=InnoDB;

-- 12. PHAN HOI HO TRO
CREATE TABLE phan_hoi_ho_tro (
    ma_phan_hoi BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ma_yeu_cau BIGINT UNSIGNED NOT NULL,
    ma_quan_tri BIGINT UNSIGNED NOT NULL,
    noi_dung_phan_hoi TEXT NOT NULL,
    ngay_tao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_phan_hoi_ho_tro_yeu_cau
        FOREIGN KEY (ma_yeu_cau)
        REFERENCES yeu_cau_ho_tro(ma_yeu_cau)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_phan_hoi_ho_tro_quan_tri
        FOREIGN KEY (ma_quan_tri)
        REFERENCES nguoi_dung(ma_nguoi_dung)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    INDEX idx_phan_hoi_ho_tro_yeu_cau (ma_yeu_cau)
) ENGINE=InnoDB;

-- =========================================================
-- DU LIEU MAU
-- =========================================================
INSERT INTO danh_muc (ten_danh_muc, slug, mo_ta) VALUES
('Trà sữa', 'tra-sua', 'Các loại trà sữa'),
('Trà trái cây', 'tra-trai-cay', 'Các loại trà trái cây'),
('Latte', 'latte', 'Các loại latte'),
('Đồ uống khác', 'do-uong-khac', 'Các loại đồ uống khác'),
('Topping', 'topping', 'Các phần topping có thể gọi thêm');

INSERT INTO san_pham (ma_danh_muc, ten_san_pham, slug, mo_ta, hinh_anh, gia_co_ban)
VALUES
((SELECT ma_danh_muc FROM danh_muc WHERE slug='tra-sua'),
 'Trà sữa truyền thống',
 'tra-sua-truyen-thong',
 'Trà sữa vị truyền thống',
 NULL,
 30000),

((SELECT ma_danh_muc FROM danh_muc WHERE slug='tra-sua'),
 'Trà sữa Matcha',
 'tra-sua-matcha',
 'Trà sữa vị matcha',
 NULL,
 35000),

((SELECT ma_danh_muc FROM danh_muc WHERE slug='topping'),
 'Trân châu đen',
 'tran-chau-den',
 'Topping trân châu đen',
 NULL,
 5000),

((SELECT ma_danh_muc FROM danh_muc WHERE slug='topping'),
 'Pudding trứng',
 'pudding-trung',
 'Topping pudding trứng',
 NULL,
 7000);

INSERT INTO kich_thuoc_san_pham (ma_san_pham, ten_kich_thuoc, gia_them)
SELECT ma_san_pham, 'M', 0
FROM san_pham
WHERE slug IN ('tra-sua-truyen-thong', 'tra-sua-matcha');

INSERT INTO kich_thuoc_san_pham (ma_san_pham, ten_kich_thuoc, gia_them)
SELECT ma_san_pham, 'L', 10000
FROM san_pham
WHERE slug IN ('tra-sua-truyen-thong', 'tra-sua-matcha');

-- Goi y:
-- Thay vi DELETE that, nen doi trang_thai = 'NGUNG' hoac 'KHOA'
-- de giu lich su don hang va ho tro.
