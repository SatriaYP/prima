-- CreateTable
CREATE TABLE `Surat` (
    `id` VARCHAR(191) NOT NULL,
    `jenisSurat` VARCHAR(191) NOT NULL,
    `judul` VARCHAR(191) NULL,
    `isi` JSON NOT NULL,
    `tanggal` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `status` VARCHAR(191) NOT NULL DEFAULT 'draft',
    `createdBy` VARCHAR(191) NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
