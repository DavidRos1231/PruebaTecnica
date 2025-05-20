package com.test.example.test_operati.services.capacidadDemanda;

import com.test.example.test_operati.models.capacidadDemanda.CapacidadDemanda;
import com.test.example.test_operati.models.capacidadDemanda.CapacidadDemandaRepository;
import com.test.example.test_operati.utils.CustomResponse;
import io.github.bonigarcia.wdm.WebDriverManager;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.time.Duration;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.CompletableFuture;

@Component
public class XlsxManager {


    @Value("${download.directory}")
    private String downloadDirectory;

    @Value("${download.url}")
    private String excelDownloadUrl;

    public CustomResponse<List<CapacidadDemanda>> saveRegisters(CapacidadDemandaRepository repository) {
        CompletableFuture<String> fileFuture = getFile();

        try {
            String absolutePath = fileFuture.join();
            if (absolutePath == null) {
                return new CustomResponse<>(null, "Error al descargar el archivo", false);
            }

            File file = new File(absolutePath);

            if (!file.exists()) {
                return new CustomResponse<>(null, "El archivo descargado no existe en la ruta: " + absolutePath, false);
            }

            try (FileInputStream fis = new FileInputStream(file);
                 Workbook workbook = new XSSFWorkbook(fis)) {

                Sheet sheet = workbook.getSheetAt(0);
                List<CapacidadDemanda> capacidadDemandaList = new ArrayList<>();

                int startRow = findStartRow(sheet);
                int[] columnIndices = findRelevantColumnIndices(sheet, startRow);

                if (columnIndices.length == 0 || columnIndices[0] == -1) {
                    return new CustomResponse<>(null, "Error al leer el archivo: No se encontraron las columnas necesarias", false);
                }

                int zonaPotenciaIndex = columnIndices[0];
                int participanteIndex = columnIndices[1];
                int subcuentaParticipanteIndex = columnIndices[2];
                int capacidadDemandaIndex = columnIndices[3];
                int requisitoAnualPotenciaIndex = columnIndices[4];
                int requisitoAnualPotenciaEficienteIndex = columnIndices[5];

                for (int rowIndex = startRow; rowIndex <= sheet.getLastRowNum(); rowIndex++) {
                    Row row = sheet.getRow(rowIndex);
                    if (row == null) continue;

                    Cell firstCell = row.getCell(zonaPotenciaIndex);
                    if (firstCell == null ||
                            (firstCell.getCellType() == CellType.STRING && firstCell.getStringCellValue().trim().isEmpty()) ||
                            (firstCell.getCellType() == CellType.BLANK)) {
                        continue;
                    }

                    try {
                        Cell zonaPotenciaCell = row.getCell(zonaPotenciaIndex);
                        Cell participanteCell = row.getCell(participanteIndex);
                        Cell subcuentaParticipanteCell = row.getCell(subcuentaParticipanteIndex);
                        Cell capacidadDemandaCell = row.getCell(capacidadDemandaIndex);
                        Cell requisitoAnualPotenciaCell = row.getCell(requisitoAnualPotenciaIndex);
                        Cell requisitoAnualPotenciaEficienteCell = row.getCell(requisitoAnualPotenciaEficienteIndex);

                        if (zonaPotenciaCell == null || participanteCell == null || subcuentaParticipanteCell == null ||
                                capacidadDemandaCell == null || requisitoAnualPotenciaCell == null ||
                                requisitoAnualPotenciaEficienteCell == null) {
                            continue;
                        }

                        String zonaPotencia = getCellStringValue(zonaPotenciaCell);
                        String participante = getCellStringValue(participanteCell);
                        String subcuentaParticipante = getCellStringValue(subcuentaParticipanteCell);
                        double capacidadDemanda = getCellNumericValue(capacidadDemandaCell);
                        double requisitoAnualPotencia = getCellNumericValue(requisitoAnualPotenciaCell);
                        double requisitoAnualPotenciaEficiente = getCellNumericValue(requisitoAnualPotenciaEficienteCell);

                        CapacidadDemanda capacidadDemandaObj = new CapacidadDemanda(
                                zonaPotencia,
                                participante,
                                subcuentaParticipante,
                                capacidadDemanda,
                                requisitoAnualPotencia,
                                requisitoAnualPotenciaEficiente
                        );

                        capacidadDemandaList.add(capacidadDemandaObj);
                    } catch (Exception e) {
                        LoggerFactory.getLogger(XlsxManager.class).error("Error al procesar fila " + rowIndex + ": " + e.getMessage());
                    }
                }

                if (capacidadDemandaList.isEmpty()) {
                    return new CustomResponse<>(null, "No se encontraron datos para procesar en el archivo", false);
                }
                deleteAllCapacidadDemanda(repository);
                List<CapacidadDemanda> savedEntities = repository.saveAll(capacidadDemandaList);
                return new CustomResponse<>(savedEntities, "Archivo procesado correctamente. Se guardaron " + savedEntities.size() + " registros", true);
            } catch (IOException e) {
                LoggerFactory.getLogger(XlsxManager.class).error("Error al procesar el archivo: " + e.getMessage());
                return new CustomResponse<>(null, "Error al procesar el archivo: " + e.getMessage(), false);
            }finally {
                if (file.exists()) {
                    if (!file.delete()) {
                        LoggerFactory.getLogger(XlsxManager.class).error("Error al eliminar el archivo: " + file.getAbsolutePath());
                    }
                } else {
                    LoggerFactory.getLogger(XlsxManager.class).error("El archivo no existe para eliminar: " + file.getAbsolutePath());
                }
            }
        } catch (Exception e) {
            LoggerFactory.getLogger(XlsxManager.class).error("Error al descargar o procesar el archivo: " + e.getMessage());
            return new CustomResponse<>(null, "Error al descargar o procesar el archivo: " + e.getMessage(), false);
        }
    }

    private void deleteAllCapacidadDemanda(CapacidadDemandaRepository repository) {
        try {
            repository.deleteAll();
        } catch (Exception e) {
            LoggerFactory.getLogger(XlsxManager.class).error("Error al eliminar los registros: " + e.getMessage());
        }
    }

    private CompletableFuture<String> getFile() {
        return CompletableFuture.supplyAsync(() -> {
            WebDriver driver = null;
            try {
                WebDriverManager.chromedriver().setup();

                ChromeOptions options = new ChromeOptions();

                // Crear directorio de descargas si no existe
                File directory = new File(downloadDirectory);
                if (!directory.exists()) {
                    directory.mkdirs();
                }

                HashMap<String, Object> chromePreferences = new HashMap<>();
                chromePreferences.put("profile.default_content_settings.popups", 0);
                chromePreferences.put("download.prompt_for_download", false);
                chromePreferences.put("download.directory_upgrade", true);
                chromePreferences.put("safebrowsing.enabled", false);
                options.setExperimentalOption("prefs", chromePreferences);

                options.addArguments("--no-sandbox");
                options.addArguments("--headless");
                options.addArguments("--disable-dev-shm-usage");
                options.addArguments("--disable-extensions");

                driver = new ChromeDriver(options);

                driver.get(excelDownloadUrl);

                WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(30));

                WebElement downloadButton = wait.until(ExpectedConditions.presenceOfElementLocated(By.xpath("//*[@id=\"contenido\"]/div/div[2]/div[2]/div[2]/table[3]/tbody/tr[3]/td[2]/a")));

                ((org.openqa.selenium.JavascriptExecutor) driver).executeScript("arguments[0].click();", downloadButton);

                // Tiempo de espera para que se complete la descarga
                // Esto puede variar mucho asi que le di mucho margen por eso puede haber cierta latencia
                Thread.sleep(5000);

                File downloadFile = new File(downloadDirectory);
                File[] files = downloadFile.listFiles();

                if (files == null || files.length == 0) {
                    LoggerFactory.getLogger(CustomResponse.class).info("Archivo no encontrado");
                    return null;
                }

                File latestFile = files[0];
                long lastModified = latestFile.lastModified();

                for (File file : files) {
                    if (file.lastModified() > lastModified) {
                        latestFile = file;
                        lastModified = file.lastModified();
                    }
                }
                return latestFile.getAbsolutePath();

            } catch (Exception e) {
                LoggerFactory.getLogger(CustomResponse.class).error("Error al obtener el archivo: " + e.getMessage());
                return null;
            } finally {
                if (driver != null) {
                    driver.quit();
                }
            }
        });
    }

    private String getCellStringValue(Cell cell) {
        if (cell == null) return "";

        switch (cell.getCellType()) {
            case STRING:
                return cell.getStringCellValue();
            case NUMERIC:
                return String.valueOf(cell.getNumericCellValue());
            case BOOLEAN:
                return String.valueOf(cell.getBooleanCellValue());
            case FORMULA:
                try {
                    return cell.getStringCellValue();
                } catch (Exception e) {
                    try {
                        return String.valueOf(cell.getNumericCellValue());
                    } catch (Exception ex) {
                        return "";
                    }
                }
            default:
                return "";
        }
    }

    private double getCellNumericValue(Cell cell) {
        if (cell == null) return 0.0;

        switch (cell.getCellType()) {
            case NUMERIC:
                return cell.getNumericCellValue();
            case STRING:
                try {
                    return Double.parseDouble(cell.getStringCellValue().replace(",", "."));
                } catch (NumberFormatException e) {
                    return 0.0;
                }
            case FORMULA:
                try {
                    return cell.getNumericCellValue();
                } catch (Exception e) {
                    return 0.0;
                }
            default:
                return 0.0;
        }
    }
    private int findStartRow(Sheet sheet) {
        for (int i = 0; i < 15; i++) {
            Row row = sheet.getRow(i);
            if (row == null) continue;

            Iterator<Cell> cellIterator = row.cellIterator();
            boolean headerFound = false;
            while (cellIterator.hasNext()) {
                Cell cell = cellIterator.next();
                if (cell.getCellType() == CellType.STRING) {
                    String cellValue = cell.getStringCellValue();
                    if (cellValue.equalsIgnoreCase("Zona de Potencia") || cellValue.equalsIgnoreCase("Participante") || cellValue.equalsIgnoreCase("Subcuenta del Participante")) {
                        headerFound = true;
                        break;
                    }
                }
            }
            if(headerFound) {
                return i + 1;
            }

        }
        return 1;
    }

 private int[] findRelevantColumnIndices(Sheet sheet, int headerRow) {
     Row row = sheet.getRow(headerRow - 1);
     if (row == null) return new int[0];

     int[] columnIndices = {-1, -1, -1, -1, -1, -1};
     int index = 0;
     String[] headers = {
         "Zona de Potencia",
         "Participante",
         "Subcuenta del Participante",
         "Capacidad Demandada (MW)",
         "Requisito Anual de Potencia (MW-año)",
         "Valor del Requisito Anual de Potencia Eficiente (MW-año)"
     };

     for (int i = 0; i < row.getPhysicalNumberOfCells(); i++) {
         Cell cell = row.getCell(i);
         if (cell != null && cell.getCellType() == CellType.STRING) {
             String cellValue = cell.getStringCellValue();
             for (String header : headers) {
                 if (cellValue.equalsIgnoreCase(header)) {
                     columnIndices[index++] = i;
                     break;
                 }
             }
             if (index == 6) break;
         }
     }
     return columnIndices;
 }
}
