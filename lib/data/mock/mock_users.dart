import '../../domain/models/user.dart';

const mockUsers = [

  User(
    id: "u1",
    username: "admin",
    password: "admin123",
    displayName: "Administrator",
    role: "admin",
  ),

  User(
    id: "u2",
    username: "alice",
    password: "alice123",
    displayName: "Alice",
    role: "user",
  ),

  User(
    id: "u3",
    username: "bob",
    password: "bob123",
    displayName: "Bob",
    role: "user",
  ),
];