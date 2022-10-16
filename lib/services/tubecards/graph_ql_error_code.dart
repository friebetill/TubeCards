class GraphQLErrorCode {
  static const String authenticationError = 'UNAUTHENTICATED';
  static const String forbiddenError = 'FORBIDDEN';
  static const String userInputError = 'BAD_USER_INPUT';

  // Custom error codes
  static const String alreadyMemberError = 'ALREADY_MEMBER';
  static const String deckIsPublic = 'DECK_IS_PUBLIC';
}
