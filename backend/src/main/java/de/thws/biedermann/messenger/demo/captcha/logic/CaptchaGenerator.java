package de.thws.biedermann.messenger.demo.captcha.logic;

import de.thws.biedermann.messenger.demo.captcha.database.CaptchaDatabaseHandler;
import de.thws.biedermann.messenger.demo.captcha.models.Line;

import java.awt.*;
import java.awt.image.BufferedImage;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.UUID;
import java.util.concurrent.ExecutionException;

public class CaptchaGenerator {
    private static final int WIDTH = 200;
    private static final int HEIGHT = 50;
    private static final int CAPTCHA_LENGTH = 7;
    private static final String CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();


    public static String createNewCaptchaImage() throws ExecutionException, InterruptedException {
        String captchaText = getNewCaptchaText();
        BufferedImage captchaImage = createCaptchaImageByText(captchaText);
        String id = UUID.randomUUID().toString();
        CaptchaDatabaseHandler.storeCaptcha(id, captchaImage, captchaText).get();

        return id;
    }

    public static BufferedImage createCaptchaImageByText(String text) {
        final BufferedImage captchaImage = new BufferedImage(WIDTH, HEIGHT, BufferedImage.TYPE_INT_RGB);
        final Graphics2D graphics2D = captchaImage.createGraphics();

        // configure graphics2d
        graphics2D.setColor(Color.white);
        graphics2D.fillRect(0, 0, WIDTH, HEIGHT);
        graphics2D.setStroke(new BasicStroke(5));
        graphics2D.setColor(Color.black);
        graphics2D.setFont(new Font("Arial", Font.BOLD, 30));

        // write text
        for (int i = 0; i < text.length(); i++) {
            int x = 15 + i * 25 + SECURE_RANDOM.nextInt(16) - 8;
            int y = 35 + SECURE_RANDOM.nextInt(16) - 8;
            graphics2D.drawString(String.valueOf(text.charAt(i)), x, y);
        }

        ArrayList<Line> lines = new ArrayList<>(2);

        // draw lines
        while( lines.size() < 2 ) {
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

        return captchaImage;
    }

    public static String getNewCaptchaText(){
        StringBuilder stringBuilder = new StringBuilder(CAPTCHA_LENGTH);
        for (int i = 0; i < CAPTCHA_LENGTH; i++) {
            stringBuilder.append(CHARACTERS.charAt(SECURE_RANDOM.nextInt(CHARACTERS.length())));
        }
        return stringBuilder.toString();
    }
}
