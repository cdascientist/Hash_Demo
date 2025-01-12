sub Main()
    game = BGE_Game(1280, 720, true) ' Initialize with HD resolution
    main_room = MainRoom(game)
    game.defineRoom(main_room)
    game.changeRoom(main_room.name)
    game.Play()
end sub'//# sourceMappingURL=./main.bs.map