enum WebsocketMessageType {
  CREATE,
  UPDATE,
  DELETE,
}

extension WebsocketMessageTypeExtension on WebsocketMessageType {
  String? get name {
    switch (this) {
      case WebsocketMessageType.CREATE:
        return 'CREATE';
      case WebsocketMessageType.UPDATE:
        return 'UPDATE';
      case WebsocketMessageType.DELETE:
        return 'DELETE';
      default:
        return null;
    }
  }

  static WebsocketMessageType fromString(String name) {
    switch (name.toLowerCase()) {
      case 'create':
        return WebsocketMessageType.CREATE;
      case 'update':
        return WebsocketMessageType.UPDATE;
      case 'delete':
        return WebsocketMessageType.DELETE;
      default:
        throw ArgumentError('Invalid WebsocketMessageType name: $name');
    }
  }
}

