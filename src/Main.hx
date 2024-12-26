package;

import j24w.FishyState;
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

class Main extends BootstrapMain {
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
        


        var run = new BuisinessGame(new Entity("dungeon-run"), Builder.widget());
        // run.state.load(Json.parse(Assets.getText("state.json")));
        
        #if sys
        kbinder.addCommand(Keyboard.S, () -> {
            sys.io.File.saveContent("state.json", Json.stringify(run.entity.getComponent(FishyState).serialize(), null, " "));
        });
        #end
        new CtxWatcher(GameRunBinder, run.entity);
        rootEntity.addChild(run.entity);
        run.entity.addComponentByType(GameRun, run);
        
        createPopup();
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
}
