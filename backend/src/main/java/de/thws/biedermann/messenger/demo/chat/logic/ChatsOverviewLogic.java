package de.thws.biedermann.messenger.demo.chat.logic;

import de.thws.biedermann.messenger.demo.authorization.model.User;
import de.thws.biedermann.messenger.demo.chat.model.Chat;
import de.thws.biedermann.messenger.demo.chat.repository.ChatsOverviewRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;
import java.util.Optional;
import java.util.concurrent.ExecutionException;

public class ChatsOverviewLogic {
    private final Logger logger;
    private final ChatsOverviewRepository chatsOverviewRepository;

    public ChatsOverviewLogic(ChatsOverviewRepository chatsOverviewRepository) {
        this.chatsOverviewRepository = chatsOverviewRepository;
        this.logger = LoggerFactory.getLogger(ChatsOverviewLogic.class);
    }

    public Optional<List<Chat>> loadChats(User user) {
        try {
            return chatsOverviewRepository.getChats(user).get();
        } catch (InterruptedException | ExecutionException e) {
            logger.error(e.getMessage());
            return Optional.empty();
        }
    }
}
