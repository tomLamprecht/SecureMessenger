package de.thws.securemessenger.features.messenging.model;

import java.util.LinkedList;
import java.util.List;

public class MessageFromFrontend {

    private String value;
    private List<FileFromFrontend> attachedFiles = new LinkedList<>();

    public MessageFromFrontend() {
    }

    public MessageFromFrontend(String value, List<FileFromFrontend> attachedFile) {
        this.value = value;
        this.attachedFiles = attachedFile;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }

    public List<FileFromFrontend> getAttachedFile() {
        return attachedFiles;
    }

    public void setAttachedFile(List<FileFromFrontend> attachedFiles) {
        this.attachedFiles = attachedFiles;
    }

    public List<FileFromFrontend> getAttachedFiles() {
        return attachedFiles;
    }

    public void setAttachedFiles(List<FileFromFrontend> attachedFiles) {
        this.attachedFiles = attachedFiles;
    }
}
