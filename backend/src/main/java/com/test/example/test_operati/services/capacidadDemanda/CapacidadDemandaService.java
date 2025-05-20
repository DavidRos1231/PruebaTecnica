package com.test.example.test_operati.services.capacidadDemanda;
import com.test.example.test_operati.models.capacidadDemanda.CapacidadDemanda;

import com.test.example.test_operati.models.capacidadDemanda.CapacidadDemandaRepository;
import com.test.example.test_operati.utils.CustomResponse;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import java.io.FileNotFoundException;
import java.util.List;

@Service
@Transactional
public class CapacidadDemandaService {

    @Autowired
    private CapacidadDemandaRepository capacidadDemandaRepository;

    @Autowired
    private XlsxManager xlsxManager;

    @Transactional(rollbackOn = Exception.class)
    public CustomResponse<List<CapacidadDemanda>> saveCapacidadDemanda() throws FileNotFoundException {
        return xlsxManager.saveRegisters(capacidadDemandaRepository);
    }


public CustomResponse<Page<CapacidadDemanda>> findAllPaginatedAndFiltered(int page, int size, String sortBy, String direction, String filter) {

    Sort.Direction sortDirection = direction.equalsIgnoreCase("DESC") ?
            Sort.Direction.DESC : Sort.Direction.ASC;
    Pageable pageable = PageRequest.of(page, size, Sort.by(sortDirection, sortBy));

    if (filter == null || filter.isEmpty() || filter.equals("none")) {
        return new CustomResponse<>(capacidadDemandaRepository.findAll(pageable), "Datos encontrados", true);
    }

    Specification<CapacidadDemanda> spec = Specification.where(null);

    spec = spec.or((root, query, cb) ->
            cb.like(cb.lower(root.get("zonaPotencia")), "%" + filter.toLowerCase() + "%"));
    spec = spec.or((root, query, cb) ->
            cb.like(cb.lower(root.get("participante")), "%" + filter.toLowerCase() + "%"));
    spec = spec.or((root, query, cb) ->
            cb.like(cb.lower(root.get("subcuentaParticipante")), "%" + filter.toLowerCase() + "%"));

    try {
        Double filterNumeric = Double.parseDouble(filter);
        spec = spec.or((root, query, cb) ->
                cb.equal(root.get("capacidadDemanda"), filterNumeric));
        spec = spec.or((root, query, cb) ->
                cb.equal(root.get("requisitoAnualPotencia"), filterNumeric));
        spec = spec.or((root, query, cb) ->
                cb.equal(root.get("requisitoAnualPotenciaEficiente"), filterNumeric));
    } catch (NumberFormatException ignored) {
    }

    return new CustomResponse<>(capacidadDemandaRepository.findAll(spec, pageable), "Datos encontrados", true);
}

}
