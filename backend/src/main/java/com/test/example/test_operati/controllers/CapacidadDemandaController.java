package com.test.example.test_operati.controllers;

import com.test.example.test_operati.models.capacidadDemanda.CapacidadDemanda;
import com.test.example.test_operati.services.capacidadDemanda.CapacidadDemandaService;
import com.test.example.test_operati.utils.CustomResponse;
import io.swagger.v3.oas.annotations.Operation;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.FileNotFoundException;
import java.util.List;

@RestController
@RequestMapping("/api/capacidad-demanda")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
//@CrossOrigin(origins = "${cors.allowed.origin}")
public class CapacidadDemandaController {

    private final CapacidadDemandaService capacidadDemandaService;
    @GetMapping("/downloadFile")
    @Operation(summary = "Descargar archivo de Excel con datos de capacidad demanda y colocarlos en la base de datos")
    public ResponseEntity<CustomResponse<List<CapacidadDemanda>>> downloadFile() throws FileNotFoundException {
        CustomResponse<List<CapacidadDemanda>> response = capacidadDemandaService.saveCapacidadDemanda();

        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.status(500).body(response);
        }
    }

    @GetMapping("/getPaginated/{page}/{size}/{sortBy}/{direction}/{filter}")
    public ResponseEntity<CustomResponse<Page<CapacidadDemanda>>> getAllPaginated(@PathVariable int page, @PathVariable int size, @PathVariable String sortBy, @PathVariable String direction,@PathVariable String filter) {
    CustomResponse<Page<CapacidadDemanda>> capacidadDemandaPage = capacidadDemandaService.findAllPaginatedAndFiltered(page, size, sortBy, direction,filter);
        return ResponseEntity.ok(capacidadDemandaPage);
    }

}
