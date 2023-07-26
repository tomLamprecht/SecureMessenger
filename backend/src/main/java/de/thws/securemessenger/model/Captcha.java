package de.thws.securemessenger.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;

import java.awt.image.BufferedImage;


public record Captcha(
        String Id,
        BufferedImage bufferedImage,
        String content) {
}
