package com.test.example.test_operati.utils;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@AllArgsConstructor
@NoArgsConstructor
@Getter
public class CustomResponse<T> {
    private T data;
    private String message;
    private boolean success;

}
