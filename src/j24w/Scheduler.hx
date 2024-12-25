package j24w;

import fu.Signal;
import update.Updatable;

class Scheduler implements Updatable {
    var time:Time;

    public function new(time) {
        this.time = time;
    }

    var tickers:Array<TickUnit> = [];

    public function update(dt:Float) {
        var tt = time.getTime();
        for (t in tickers) {
            while (t.activationTime < tt) {
                t.activationTime += t.cd;
                t.onActivate.dispatch();
            }
        }
    }

    public function addTicker(t) {
        tickers.push(t);
    }
    
    public function removeTicker(t) {
        tickers.push(t);
    }
}

class TickUnit {
    public var cd = 1.;
    public var activationTime:Float;
    public var onActivate:Signal<Void->Void> = new Signal();

    public function new() {}
}
