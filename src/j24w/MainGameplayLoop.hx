package j24w;

import ec.PropertyComponent;
import bootstrap.GameRunBase;
import gameapi.GameRun;
import haxe.Json;
import j24w.CheckoutGui.CheckoutView;
import j24w.CheckoutGui.GameOverView;
import j24w.FishyState.AllStats;
import j24w.Gui.GameView;

class MainGameplayLoop extends GameRunBase {
    @:once var state:FishyState;
    @:once var time:Time;
    @:once var buisiness:BuisinessGame;
    @:once var checkout:CheckoutRun;
    @:once var gui:GameView;
    @:once var speed:SpeedProp;

    var act:GameRun;

    override function init() {
        super.init();
        checkout.gameOvered.listen(checkoutDone);
    }

    override function startGame() {
        checkout.reset();
        act = buisiness;
        buisiness.startGame();
    }

    function checkoutDone() {
        act = buisiness;
    }

    override function update(dt:Float) {
        var curMon = Math.floor(time.getTime() / 30);
        var curDay = Math.floor(time.getTime());
        gui.day.text = "" + curDay;
        gui.month.text = "" + curMon;
        if (curMon > state.month) {
            act = checkout;
            checkout.startGame();
        }
        for (i in 0...speed.value)
            act.update(dt);
    }

    // override function getView():Placeholder2D {
    //     return buisiness.getView();
    // }
}

abstract Speed(Array<Int>)  {
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

class SpeedProp extends PropertyComponent<Speed>{
    public function new() {
        super();
        value = new Speed();
    }
}

// class TollProperty extends PropertyComponent<Int> { }

class CheckoutRun extends GameRunBase {
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
        gameOvered.dispatch();
        popup.close();
    }

    function currentToll() {
        return Std.int(20 + 5 * state.month * 1.5);
    }

    function dumpState() {
        #if sys
        sys.io.File.saveContent('$session-${state.month}.json', Json.stringify(state.serialize(), null, " "));
        #end
    }
}
