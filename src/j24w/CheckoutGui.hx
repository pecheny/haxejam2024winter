package j24w;

import Main.Lifecycle;
import al.layouts.PortionLayout;
import ec.Signal;
import fancy.domkit.Dkit;

class GameOverView extends BaseDkit {
    public var onDone:Signal<Void->Void> = new Signal();

    @:once var l:Lifecycle;

    static var SRC = <game-over-view vl={PortionLayout.instance}>
            ${fui.quad(__this__.ph, 0xBC0B0A0A)}
            <label(b().v(pfr, 0.3).b()) id="name"  style={"small-text"} text={"game over"} />
            <button(b().v(pfr, 0.1).b()) text={"ok"} onClick={done} />

    </game-over-view>

    function done() {
        // onDone.dispatch();
        l.showMenu();
    }
}

class CheckoutView extends BaseDkit {
    public var onDone:Signal<Void->Void> = new Signal();

    static var SRC = <checkout-view vl={PortionLayout.instance}>
            ${fui.quad(__this__.ph, 0xBC0B0A0A)}

            <label(b().v(pfr, 0.3).b()) id="name"  style={"small-text"} text={"month over, toll payed"} />
            <button(b().v(pfr, 0.1).b()) text={"ok"} onClick={done} />
    </checkout-view>

    function done() {
        onDone.dispatch();
    }
}
