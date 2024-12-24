package j24w;

import stset.Stats;
import haxe.ds.ReadOnlyArray;
import ec.Signal;
import j24w.Building;

class FishyState {
    // public var buildings:Array<Building>;
    public var slots(default, null):ReadOnlyArray<Slot>;
    public var stats(default, null):AllStats = new AllStats({});

    public function new() {
        slots = [for (i in 0...9) new Slot()];
    }
}

class Slot {
    public var value(default, set):SlotValue = Empty;
    public var onChange(default, null) = new Signal<Void->Void>();

    public function new() {}

    function set_value(value:SlotValue):SlotValue {
        this.value = value;
        onChange.dispatch();
        return value;
    }
}

enum SlotValue {
    Building(b:Building);
    Empty;
}

class AllStats implements StatsSet {
    public var shell(default, null):CapGameStat<Int>;

    // public var alg_mp(default, null):TempIncGameStat<Int>;
    public var algae(default, null):GameStat<Int>; // водрослт
    public var bivalvia(default, null):GameStat<Int>; // двустворчатые
    public var buck(default, null):GameStat<Int>;

    public function initAll(data:{?hlt:Int}) {
        for (k in keys) {
            var stat = get(k);
            if (Reflect.hasField(data, k)) {
                stat.loadData(Reflect.field(data, k));
            } else
                stat.value = 0;
        }
    }

    public function getData() {
        var stats = {};
        for (k in this.keys) {
            Reflect.setField(stats, k, this.get(k).getData());
        }
        return stats;
    }
}
