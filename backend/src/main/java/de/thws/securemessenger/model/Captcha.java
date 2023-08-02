package de.thws.securemessenger.model;

import java.awt.image.BufferedImage;


public record Captcha(
        String Id,
        BufferedImage bufferedImage,
        String content) {
}
