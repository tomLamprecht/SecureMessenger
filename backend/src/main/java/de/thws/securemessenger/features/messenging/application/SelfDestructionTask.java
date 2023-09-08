package de.thws.securemessenger.features.messenging.application;

import de.thws.securemessenger.model.Message;
import de.thws.securemessenger.repositories.MessageRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaDelete;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Root;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.util.List;

@Component
public class SelfDestructionTask {

    @PersistenceContext
    private EntityManager entityManager;

    @Autowired
    private MessageRepository messageRepository;

    @Autowired
    private SubscriptionWebSocket subscriptionWebSocket;

    @Scheduled(fixedRate = 100)
    public void deleteAllExpired() {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<Message> query = cb.createQuery(Message.class);
        Root<Message> root = query.from(Message.class);
        query.where(cb.lessThanOrEqualTo(root.get("selfDestructionTime"), cb.currentTimestamp()));

        List<Message> resultList = entityManager.createQuery(query).getResultList();

        messageRepository.deleteAll(resultList);
        resultList.forEach(m -> subscriptionWebSocket.notifyAllSessionsOfDeletedMessage(m.id(), m.chat().id()));
    }

}
