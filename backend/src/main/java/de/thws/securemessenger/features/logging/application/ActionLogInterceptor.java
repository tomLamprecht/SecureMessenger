//package de.thws.securemessenger.features.logging.application;
//
//import de.thws.securemessenger.model.AccountActionLog;
//import de.thws.securemessenger.repositories.AccountActionLogRepository;
//import jakarta.servlet.http.HttpServletRequest;
//import jakarta.servlet.http.HttpServletResponse;
//import org.springframework.stereotype.Component;
//import org.springframework.web.servlet.HandlerInterceptor;
//
//import java.time.LocalDateTime;
//
//@Component
//public class ActionLogInterceptor implements HandlerInterceptor  {
//
//    private static final String PUBLIC_KEY_HEADER = "x-public-key";
//    private final AccountActionLogRepository accountActionLogRepository;
//
//    public ActionLogInterceptor(AccountActionLogRepository accountActionLogRepository) {
//        this.accountActionLogRepository = accountActionLogRepository;
//    }
//
//    @Override
//    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
//        logCurrentAction(request);
//        return validateRequest(request);
//    }
//
//    private void logCurrentAction(HttpServletRequest request) {
//        String uri = request.getRequestURI();
//        String publicKeyString = request.getHeader(PUBLIC_KEY_HEADER);
//        AccountActionLog newActionLog = new AccountActionLog(publicKeyString, uri);
//        accountActionLogRepository.save(newActionLog);
//    }
//
//    private boolean validateRequest(HttpServletRequest request) {
//        LocalDateTime startTimestamp = LocalDateTime.now().minusSeconds(30);
//        String uri = request.getRequestURI();
//        String publicKeyString = request.getHeader(PUBLIC_KEY_HEADER);
//        return 20 < accountActionLogRepository.getCountOfRequestsSince(publicKeyString, uri, startTimestamp);
//    }
//
//}
