"""Verify that GPAW was built with working LibXC support."""

from gpaw import get_libraries
from gpaw.xc.libxc import LibXC


def test_libxc():
    # Check that LibXC support was enabled at build time.
    libraries = get_libraries()
    assert libraries["libxc"], "GPAW was built without LibXC support."

    # Check that a LibXC exchange functional can be initialized.
    xc = LibXC("GGA_X_PBE")
    assert xc.type == "GGA", f"Expected a GGA functional, got {xc.type!r}."

    print("LibXC support verified successfully.")


if __name__ == "__main__":
    test_libxc()
