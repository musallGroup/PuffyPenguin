from psychopy.visual import Window, ImageStim


class VisualStimulus:
    def __init__(self, screen=0, screen_size=(1280, 720), wait_blanking=True, fullscr=True):
        # win = Window(size=(1280, 720), screen=1, fullscr=True)
        # stim = ImageStim(win, size=2, units='norm', interpolate=True)
        self._win = Window(size=screen_size, screen=screen, fullscr=fullscr, waitBlanking=wait_blanking)
        self._stim = ImageStim(self._win, size=2, units='norm', interpolate=True)
        # self.duration = 3
        # self.frame_ids = list()
    #

    def change_image(self, image_path):
        self._stim.image = image_path
    #

    def draw(self):
        self._stim.draw()
    #

    def flip(self):
        self._win.flip()
    #

    def close(self):
        self._win.close()
    #
#
