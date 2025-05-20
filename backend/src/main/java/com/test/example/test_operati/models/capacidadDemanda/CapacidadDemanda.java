package com.test.example.test_operati.models.capacidadDemanda;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "capacidad_demanda")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class CapacidadDemanda {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;

    @Column(name = "zona_potencia",columnDefinition = "varchar(10)")
    private String zonaPotencia;

    @Column(name = "participante",columnDefinition = "varchar(10)")
    private String participante;

    @Column(name = "subcuenta_participante",columnDefinition ="varchar(10)")
    private String subcuentaParticipante;

    @Column(name = "capacidad_demanda")
    private double capacidadDemanda;

    @Column(name = "requisito_anual_potencia")
    private double requisitoAnualPotencia;

    @Column(name = "requisito_anual_potencia_eficiente")
    private double requisitoAnualPotenciaEficiente;

    public CapacidadDemanda(String zonaPotencia, String participante, String subcuentaParticipante, double capacidadDemanda, double requisitoAnualPotencia, double requisitoAnualPotenciaEficiente) {
        this.zonaPotencia = zonaPotencia;
        this.participante = participante;
        this.subcuentaParticipante = subcuentaParticipante;
        this.capacidadDemanda = capacidadDemanda;
        this.requisitoAnualPotencia = requisitoAnualPotencia;
        this.requisitoAnualPotenciaEficiente = requisitoAnualPotenciaEficiente;
    }
}
