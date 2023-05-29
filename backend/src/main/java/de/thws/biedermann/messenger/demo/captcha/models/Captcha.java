package de.thws.biedermann.messenger.demo.captcha.models;

import java.awt.image.BufferedImage;

public record Captcha(String Id, BufferedImage bufferedImage, String content) {
}
