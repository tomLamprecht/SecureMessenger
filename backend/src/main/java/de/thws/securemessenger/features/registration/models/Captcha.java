package de.thws.securemessenger.features.registration.models;

import java.awt.image.BufferedImage;

public record Captcha(String Id, BufferedImage bufferedImage, String content) {
}
