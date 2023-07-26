package de.thws.securemessenger.chat;

class ChatsControllerTest {
/*
    private ChatsController chatsController;

    private final Account account = new Account( 1, "test" );
    private final Instant now = Instant.parse( "2022-10-27T10:00:00.00Z" );
    private final ChatToUserRepository chatToUserRepositoryStub = new ChatToUserTestStub();

    @BeforeEach
    void setUp() {
        CurrentAccount currentAccount = new CurrentAccount();
        currentAccount.setUser(account);
        FriendshipRepository friendshipRepositoryMock = mock( FriendshipRepository.class );
        InstantNowRepository instantNowRepositoryMock = mock( InstantNowRepository.class );

        when( friendshipRepositoryMock.readFriendship( 1, 2 ) ).thenReturn( Optional.of( new Friendship( 1, 2, true ) ) );
        when( instantNowRepositoryMock.get() ).thenReturn( now );

        chatsController = new ChatsController(currentAccount, chatToUserRepositoryStub , new MessageTestStub(), friendshipRepositoryMock, instantNowRepositoryMock );
    }

    @Test
    void test_chats_post() {
        ChatToAccount chatToAccount = new ChatToAccount( -1, 2, 1, "key", false, null, null );
        ChatToAccount expected = new ChatToAccount( 1, 2, 1, "key", false, now, null );
        chatsController.postChatToUser(chatToAccount);

        Optional<ChatToAccount> result = chatToUserRepositoryStub.readChatToUser( 1 );
        assertTrue(result.isPresent());

        assertEquals( expected, result.get() );
    }
*/
}