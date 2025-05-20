package com.test.example.test_operati.models.capacidadDemanda;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CapacidadDemandaRepository extends JpaRepository<CapacidadDemanda, Long> {

    Page<CapacidadDemanda> findAll(Specification<CapacidadDemanda> spec, Pageable pageable);
}
