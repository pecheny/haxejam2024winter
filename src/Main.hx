package;


import j24w.BuisinessGame;
import j24w.Gui;
import openfl.ui.Keyboard;
import bootstrap.BootstrapMain;
import ec.CtxWatcher;
import ec.Entity;
import gameapi.GameRun;
import gameapi.GameRunBinder;
import haxe.Json;
import openfl.utils.Assets;

using a2d.transform.LiquidTransformer;
using al.Builder;

class Main extends BootstrapMain {
    public function new() {
        super();
        var pause = rootEntity.addComponent(new Pause());
        var kbinder = new utils.KeyBinder();

        kbinder.addCommand(Keyboard.P, () -> {
            pause.pause(!pause.paused);
        });
        
        ec.DebugInit.initCheck.listen(()->trace("bar"));
        kbinder.addCommand(Keyboard.A, () -> {
            ec.DebugInit.initCheck.dispatch();
        });

        var run = new BuisinessGame (new Entity("dungeon-run"), Builder.widget());
        // run.state.load(Json.parse(Assets.getText("state.json")));
        // var run = new ButtonTester(new Entity("dungeon-run"), Builder.widget());

        new CtxWatcher(GameRunBinder, run.entity);
        // run.entity.addComponentByType(GameRun,new GameReadyChecker2(run));
        rootEntity.addChild(run.entity);
        run.entity.addComponentByType(GameRun, run);

    }
    
}
