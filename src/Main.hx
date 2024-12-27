package;

import j24w.Menu;
import bootstrap.SimpleRunBinder;
import j24w.CheckoutGui.CheckoutView;
import j24w.CheckoutGui.GameOverView;
import j24w.FishyState;
import j24w.MainGameplayLoop;
import j24w.Popup;
import a2d.Placeholder2D;
import fu.ui.Button;
import fu.GuiDrawcalls;
import al.ec.WidgetSwitcher;
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

class Main extends BootstrapMain implements Lifecycle {
    var sr:SimpleRunBinder;
    var run:GameRun;

    public function new() {
        super();
        var pause = rootEntity.addComponent(new Pause());
        var kbinder = new utils.KeyBinder();

        kbinder.addCommand(Keyboard.P, () -> {
            pause.pause(!pause.paused);
        });

        kbinder.addCommand(Keyboard.A, () -> {
            ec.DebugInit.initCheck.dispatch();
        });

        kbinder.addCommand(Keyboard.ESCAPE, () -> {
            showMenu();
        });

        var entity = rootEntity;
        var state = entity.addComponent(new FishyState());

        SpeedProp.getOrCreate(entity);
        entity.addComponent(state.time);
        entity.addComponentByType(Lifecycle, this);
        entity.addComponent(state.stats);
        var go = entity.addComponent(new GameOverView(Builder.widget()));
        // go.onDone.listen(startNewGame);
        var mw = Builder.widget();
        entity.addComponent(new GameView(mw));
        entity.addComponent(new CheckoutView(Builder.widget()));
        var bg = entity.addComponent(new BuisinessGame(new Entity("buisiness-run"), Builder.widget()));
        entity.addChild(bg.entity);
        var co = entity.addComponent(new CheckoutRun(new Entity("checlout-run"), Builder.widget()));
        entity.addChild(co.entity);

        //
        run = new MainGameplayLoop(new Entity("mainloop"), mw);
        // run.state.load(Json.parse(Assets.getText("state.json")));

        #if sys
        kbinder.addCommand(Keyboard.S, () -> {
            sys.io.File.saveContent("state.json", Json.stringify(rootEntity.getComponent(FishyState).serialize(), null, " "));
        });
        #end
        new CtxWatcher(GameRunBinder, run.entity);
        rootEntity.addChild(run.entity);
        // run.entity.addComponentByType(GameRun, run);

        createPopup();
        var m = new Menu(Builder.widget());
        rootEntity.addComponent(m);
        fui.makeClickInput(m.ph);
        rootEntity.getComponent(WidgetSwitcher).switchTo(m.ph);
        run.entity.addComponentByType(GameRun, run);
        showMenu();

    }

    override function createRunWrapper() {
        sr = new SimpleRunBinder(rootEntity, null);
    }

    public function newGame() {
        // if (!run.entity.hasComponent(GameRun))
        //     run.entity.addComponentByType(GameRun, run);
        rootEntity.getComponent(FishyState).load(Json.parse(openfl.utils.Assets.getText("state.json")));
        @:privateAccess sr.startGame();
        rootEntity.getComponent(Popup).close();
        rootEntity.getComponent(Pause).pause(false);
    }

    public function resume() {
        rootEntity.getComponent(WidgetSwitcher).switchTo(run.getView());
        rootEntity.getComponent(Pause).pause(false);
    }

    public function saveGame():Void {
        #if sys
        sys.io.File.saveContent("save.json", Json.stringify(rootEntity.getComponent(FishyState).serialize(), null, " "));
        #end
    }

    public function loadGame():Void {
        #if sys
        if (!sys.FileSystem.exists("save.json"))
            return;
        rootEntity.getComponent(FishyState).load(Json.parse(sys.io.File.getContent("save.json")));
        @:privateAccess sr.startGame();
        rootEntity.getComponent(Popup).close();
        rootEntity.getComponent(Pause).pause(false);
        #end
    }

    public function showMenu():Void {
        rootEntity.getComponent(Pause).pause(true);
        rootEntity.getComponent(Popup).close();
        rootEntity.getComponent(WidgetSwitcher).switchTo(rootEntity.getComponent(Menu).ph);
    }

    override function iniUpdater() {
        var updater = new bootstrap.RunUpdater();
        // fui already uses updater with fps limit
        // which may be crusial on html targets
        fui.updater.addUpdatable(updater);
        rootEntity.addComponentByType(ginp.api.GameInputUpdaterBinder, updater);
        rootEntity.addComponent(new update.UpdateBinder(updater));
    }

    function createPopup() {
        var ph = Builder.sibling(rootEntity.getComponent(Placeholder2D));
        ph.entity.name = "popup";
        fui.makeClickInput(ph);
        var popup = ph.entity;
        fui.createContainer(popup, Xml.parse(GuiDrawcalls.DRAWCALLS_LAYOUT).firstElement());
        var switcher = new WidgetSwitcher(ph);
        rootEntity.addComponent(new Popup(switcher, fui));
    }

    override function textStyles() {
        super.textStyles();
        var ts = fui.textStyles;
        ts.newStyle("right")
            .withSize(sfr, .07) // .withPadding(horizontal, sfr, 0.1)
            .withAlign(vertical, Center)
            .withAlign(horizontal, Backward)
            .build();
    }
}

interface Lifecycle {
    function newGame():Void;
    function saveGame():Void;
    function loadGame():Void;
    function resume():Void;
    function showMenu():Void;
}
