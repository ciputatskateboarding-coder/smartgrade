package edu.sistem.pemeriksa_pg.controller;

import edu.sistem.pemeriksa_pg.model.HasilSiswa;
import org.apache.poi.ss.usermodel.*;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

@Controller
public class PemeriksaController {

    @GetMapping("/")
    public String tampilkanHalaman() {
        return "index"; 
    }

    @PostMapping("/proses-nilai")
    public String prosesNilai(@RequestParam("fileExcel") MultipartFile fileExcel,
                              @RequestParam("kunciJawaban") String kunciJawaban,
                              Model model) {
        
        List<HasilSiswa> daftarHasil = new ArrayList<>();
        String kunci = kunciJawaban.trim().toUpperCase();
        double poinMaksPg = (double) kunci.length();

        try (InputStream is = fileExcel.getInputStream();
             Workbook workbook = WorkbookFactory.create(is)) {
             
            Sheet sheet = workbook.getSheetAt(0);

            // AMBIL BOBOT MAKSIMAL (Dari Baris ke-2 / Index 1)
            Row rowBobot = sheet.getRow(1);
            double poinMaksIsian = (rowBobot.getCell(2) != null) ? rowBobot.getCell(2).getNumericCellValue() : 0;
            double poinMaksEssai = (rowBobot.getCell(3) != null) ? rowBobot.getCell(3).getNumericCellValue() : 0;
            
            double totalPoinMaksimum = poinMaksPg + poinMaksIsian + poinMaksEssai;

            // PROSES DATA SISWA (Mulai Baris ke-3 / Index 2)
            for (int i = 2; i <= sheet.getLastRowNum(); i++) {
                Row row = sheet.getRow(i);
                if (row == null) continue;

                String nama = row.getCell(0).getStringCellValue();
                String jawabanSiswa = row.getCell(1).getStringCellValue().trim().toUpperCase();

                int benar = 0;
                int salah = 0;

                for (int j = 0; j < kunci.length(); j++) {
                    if (j < jawabanSiswa.length() && jawabanSiswa.charAt(j) == kunci.charAt(j)) {
                        benar++;
                    } else {
                        salah++;
                    }
                }

                double skorIsian = (row.getCell(2) != null) ? row.getCell(2).getNumericCellValue() : 0;
                double skorEssai = (row.getCell(3) != null) ? row.getCell(3).getNumericCellValue() : 0;

                // Hitung Nilai Akhir (Skala 100)
                double totalPoinSiswa = (double) benar + skorIsian + skorEssai;
                double nilaiFinal = (totalPoinSiswa / totalPoinMaksimum) * 100;

                daftarHasil.add(new HasilSiswa(
                    nama, benar, salah, 
                    String.valueOf(benar), 
                    skorIsian, 
                    skorEssai, 
                    String.format("%.2f", nilaiFinal)
                ));
            }

            model.addAttribute("pesanSukses", "Data berhasil dihitung dengan Skala 100!");
            model.addAttribute("dataHasil", daftarHasil);

        } catch (Exception e) {
            model.addAttribute("pesanError", "Gagal membaca data. Pastikan Baris 2 Excel berisi angka poin maksimal.");
        }

        return "index";
    }
}