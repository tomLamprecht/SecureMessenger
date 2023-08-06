package de.thws.securemessenger.util;

import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.stereotype.Service;
import org.springframework.util.FileCopyUtils;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

@Service
public class FileResourceService {

    private final ResourceLoader resourceLoader;

    public FileResourceService( ResourceLoader resourceLoader) {
        this.resourceLoader = resourceLoader;
    }

    public String readResourceFile(String filePath) {
        Resource resource = resourceLoader.getResource("classpath:" + filePath);

        try ( InputStream in = resource.getInputStream()) {
            byte[] bdata = FileCopyUtils.copyToByteArray(in);
            return new String(bdata, StandardCharsets.UTF_8);
        } catch ( IOException e) {
            throw new RuntimeException("Error occurred while reading file", e);
        }
    }
}
