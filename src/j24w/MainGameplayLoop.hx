package j24w;

import a2d.Placeholder2D;
import gameapi.GameRun;
import j24w.CheckoutGui.CheckoutView;
import j24w.CheckoutGui.GameOverView;
import ec.PropertyComponent;
import j24w.FishyState.AllStats;
import bootstrap.GameRunBase;

class MainGameplayLoop extends GameRunBase {
    @:once var state:FishyState;
    @:once var time:Time;
    @:once var buisiness:BuisinessGame;
    @:once var checkout:CheckoutRun;

    var act:GameRun;

    override function init() {
        super.init();
        checkout.gameOvered.listen(checkoutDone);
    }

    override function startGame() {
        act = buisiness;
        buisiness.startGame();
    }

    function checkoutDone() {
        act = buisiness;
    }

    override function update(dt:Float) {
        var curMon = Math.floor(time.getTime() / 10);
        if (curMon > state.month) {
            act = checkout;
            checkout.startGame();
        }
        act.update(dt);
    }

    override function getView():Placeholder2D {
        return buisiness.getView();
    }
}

// class TollProperty extends PropertyComponent<Int> { }

class CheckoutRun extends GameRunBase {
    @:once var stats:AllStats;
    @:once var state:FishyState;
    @:once var popup:Popup;
    @:once var go:GameOverView;
    @:once var co:CheckoutView;

    override function startGame() {
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
        return Std.int(20 + 20 * state.month * 1.2);
    }
}
