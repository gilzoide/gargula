/// Shortcut for creating a Game instance, creating the passed objects and running
mixin template Main(Game, ObjectsToCreate...)
{
    version (D_BetterC)
    {
        extern (C) int main(int argc, const char** argv)
        {
            auto game = Game(argc, argv);
            static foreach (type; ObjectsToCreate)
            {
                game.create!type;
            }
            game.run();
            return 0;
        }
    }
    else
    {
        int main(string[] args)
        {
            auto game = Game(args);
            static foreach (type; ObjectsToCreate)
            {
                game.create!type;
            }
            game.run();
            return 0;
        }
    }
}

