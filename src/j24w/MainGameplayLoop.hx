package j24w;

import al.Builder;
import bootstrap.GameRunBase;
import ec.Entity;
import ec.PropertyComponent;
import gameapi.CheckedActivity;
import gameapi.GameRun;
import haxe.Json;
import j24w.CheckoutGui.BuyItem;
import j24w.CheckoutGui.CheckoutView;
import j24w.CheckoutGui.GameOverView;
import j24w.FishyData.ItemsDef;
import j24w.FishyState.AllStats;
import j24w.Gui.GameView;
import j24w.Perks.ItemsProperty;
import utils.Random;

class MainGameplayLoop extends GameRunBase {
    @:once var state:FishyState;
    @:once var time:Time;
    @:once var buisiness:BuisinessGame;
    // @:once var checkout:GameRun;
    // @:once var pickup:GameRun;
    @:once var gui:GameView;
    @:once var speed:SpeedProp;
    var act:GameRun;
    var checked:Array<CheckedActivity> = [];

    public function new(e, v) {
        super(e, v);
        addChecked(new CheckoutRun(new Entity("checlout-run"), Builder.widget()));
        addChecked(new PickItem(new Entity("pickup-run"), Builder.widget()));
    }

    override function startGame() {
        act = buisiness;
        buisiness.startGame();
    }

    function addChecked(ch:CheckedActivity) {
        checked.push(ch);
        ch.gameOvered.listen(checkoutDone);
        entity.addChild(ch.entity);
    }

    function checkoutDone() {
        for (ch in checked) {
            if (ch.shouldActivate()) {
                act = ch;
                act.startGame();
                return;
            }
        }
        act = buisiness;
    }

    var checkCounter = 0;

    override function update(dt:Float) {
        if (act == buisiness) {
            checkCounter++;
            if (checkCounter > 10) {
                checkCounter = 0;
                checkoutDone();
            }
            if(act!=buisiness)
                return;
            var curDay = Math.floor(time.getTime());
            gui.day.text = "" + curDay;
            gui.month.text = "" + state.month;
            for (i in 0...speed.value)
                act.update(dt);
        }
    }
}

abstract Speed(Array<Int>) {
    public inline function new() {
        this = [1, 1, 3, 5, 10];
    }

    @:op(A++) public inline function inc() {
        var i = this[0];
        i++;
        if (i >= this.length)
            i = 1;
        this[0] = i;
        return this;
    }

    @:to function getInt():Int
        return this[this[0]];

    @:to function toString():String
        return "" + this[this[0]];
}

class SpeedProp extends PropertyComponent<Speed> {
    public function new() {
        super();
        value = new Speed();
    }
}

class CheckoutRun extends GameRunBase implements CheckedActivity {
    override function reset() {
        super.reset();
        var d = Date.now();
        session = "" + d.getDay() + "-" + d.getHours() + "-" + d.getMinutes();
    }

    @:once var stats:AllStats;
    @:once var state:FishyState;
    @:once var popup:Popup;
    @:once var go:GameOverView;
    @:once var co:CheckoutView;
    var session:String;

    override function startGame() {
        dumpState();
        state.month++;
        if (stats.shell.value < stats.toll.value) {
            popup.switchTo(go.ph);
        } else {
            stats.shell.value -= stats.toll.value;
            stats.toll.value = currentToll();
            popup.switchTo(co.ph);
        }
    }

    override function init() {
        co.onDone.listen(coDone);
    }

    function coDone() {
        popup.close();
        gameOvered.dispatch();
    }

    function currentToll() {
        return Std.int(20 + 4 * state.month * 1.5);
    }

    function dumpState() {
        #if sys
        sys.io.File.saveContent('$session-${state.month}.json', Json.stringify(state.serialize(), null, " "));
        #end
    }

    public function shouldActivate():Bool {
        var curMon = Math.floor(state.time.getTime() / 30);
        return (curMon > state.month);
    }
}

class PickItem extends GameRunBase implements CheckedActivity {
    @:once var gui:BuyItem;
    @:once var items:ItemsProperty;
    @:once var itemsDef:ItemsDef;
    @:once var perks:Perks;
    @:once var popup:Popup;
    @:once var state:FishyState;

    var choices:Array<String>;

    override function init() {
        gui.onChoice.listen(clickHandler);
    }

    function clickHandler(n:Int) {
        popup.close();
        perks.addItem(choices[n]);
        gameOvered.dispatch();
    }

    override function startGame() {
        popup.switchTo(gui.ph);
        var available = Reflect.fields(itemsDef.get("")).filter(iid -> !items.value.contains(iid));
        Random.shuffle(available);
        choices = available.slice(0, 3);
        if (choices.length < 1) {
            gameOvered.dispatch();
            return;
        }
        gui.initChoices(choices);
    }

    public function shouldActivate():Bool {
        return Math.floor(state.month / 6) > items.value.length;
    }
}
