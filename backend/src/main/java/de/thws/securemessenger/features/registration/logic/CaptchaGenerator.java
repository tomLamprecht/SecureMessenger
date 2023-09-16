package de.thws.securemessenger.features.registration.logic;

import de.thws.securemessenger.features.registration.models.Line;
import de.thws.securemessenger.repositories.CaptchaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.awt.*;
import java.awt.image.BufferedImage;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.UUID;

@Service
public class CaptchaGenerator {
    private static final int WIDTH = 200;
    private static final int HEIGHT = 50;
    private static final int CAPTCHA_LENGTH = 7;
    private static final String CHARACTERS = "ABCDEFGHJKMNOPQRSTUVWYZabcdefghkmnopqrstwyz023456789";
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();
    private final CaptchaRepository captchaRepository;

    @Autowired
    public CaptchaGenerator(CaptchaRepository captchaRepository) {
        this.captchaRepository = captchaRepository;
    }

    public String createNewCaptchaImage() {
        final String captchaText = getNewCaptchaText();
        final BufferedImage captchaImage = createCaptchaImageByText(captchaText);
        final String id = UUID.randomUUID().toString();
        captchaRepository.storeCaptcha(id, captchaImage, captchaText);

        return id;
    }

    public BufferedImage createCaptchaImageByText(String text) {
        BufferedImage captchaImage = new BufferedImage(WIDTH, HEIGHT, BufferedImage.TYPE_INT_RGB);
        Graphics2D graphics2D = captchaImage.createGraphics();

        configureGraphics(graphics2D);
        writeText(graphics2D, text);
        drawLines(graphics2D);

        return captchaImage;
    }

    private void configureGraphics(Graphics2D graphics2D) {
        graphics2D.setColor(Color.WHITE);
        graphics2D.fillRect(0, 0, WIDTH, HEIGHT);
        graphics2D.setStroke(new BasicStroke(5));
        graphics2D.setColor(Color.BLACK);
        graphics2D.setFont(new Font("Arial", Font.BOLD, 30));
    }

    private void writeText(Graphics2D graphics2D, String text) {
        for (int i = 0; i < text.length(); i++) {
            int x = 15 + i * 25 + SECURE_RANDOM.nextInt(16) - 8;
            int y = 35 + SECURE_RANDOM.nextInt(16) - 8;
            graphics2D.drawString(String.valueOf(text.charAt(i)), x, y);
        }
    }

    private void drawLines(Graphics2D graphics2D) {
        ArrayList<Line> lines = new ArrayList<>(2);

        while (lines.size() < 2) {
            int x1 = SECURE_RANDOM.nextInt(60) + 15;
            int y1 = SECURE_RANDOM.nextInt(HEIGHT - 25) + 10;
            int x2 = SECURE_RANDOM.nextInt(40) + 150;
            int y2 = SECURE_RANDOM.nextInt(HEIGHT - 20) + 10;

            Line newLine = new Line(x1, y1, x2, y2);

            if (lines.stream().anyMatch(l -> Math.abs(l.y1() - y1) < 10 || Math.abs(l.y2() - y2) < 10)) {
                continue;
            }

            lines.add(newLine);
            graphics2D.drawLine(x1, y1, x2, y2);
        }
    }

    public String getNewCaptchaText() {
        final StringBuilder stringBuilder = new StringBuilder(CAPTCHA_LENGTH);
        for (int i = 0; i < CAPTCHA_LENGTH; i++) {
            stringBuilder.append(CHARACTERS.charAt(SECURE_RANDOM.nextInt(CHARACTERS.length())));
        }
        return stringBuilder.toString();
    }
}
