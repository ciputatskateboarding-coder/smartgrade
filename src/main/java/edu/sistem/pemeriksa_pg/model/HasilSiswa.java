package edu.sistem.pemeriksa_pg.model;

public record HasilSiswa(
    String nama, 
    int benar, 
    int salah, 
    String nilaiPg,     // Poin PG yang didapat
    double nilaiIsian,  // Poin Isian dari Excel
    double nilaiEssai,  // Poin Essai dari Excel
    String totalNilai   // Hasil akhir skala 100
) {}