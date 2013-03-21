using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Shapes;
using Microsoft.Phone.Controls;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using Microsoft.Xna.Framework.Audio;
using System.IO.IsolatedStorage;

namespace PocketPiglet
{
    public partial class PuzzleGamePage : PhoneApplicationPage
    {
        private Image puzzleImage;
        private bool loadOnLayoutUpdate;
        private string typeLevel;
        private string typeBackground;
        private int sizeWidth, sizeHeight;
        private int[,] arrItems;
        private Point emptyPoint;
        Image imageEmpty;
        private Random rnd;
        private bool isGamePlay;
        private string animationPigletPlay;
        private string lastGamePiglet;
        public PuzzleGamePage()
        {
            InitializeComponent();
            this.rnd = new Random();
            this.loadOnLayoutUpdate = false;
            IsolatedStorageSettings.ApplicationSettings.TryGetValue<string>("AnimationPigletPlay", out this.animationPigletPlay);
            IsolatedStorageSettings.ApplicationSettings.TryGetValue<string>("LastGamePiglet", out this.lastGamePiglet);
            IsolatedStorageSettings.ApplicationSettings["LastGamePiglet"] = "puzzle";
            IsolatedStorageSettings.ApplicationSettings["PuzzleGameState"] = true;
            IsolatedStorageSettings.ApplicationSettings.Save();
        }

        private void GridPuzzle_LayoutUpdated(object sender, EventArgs e)
        {
            if (!this.loadOnLayoutUpdate)
            {
                this.loadOnLayoutUpdate = true;

            }
        }

        protected override void OnNavigatedTo(NavigationEventArgs e)
        {
            base.OnNavigatedTo(e);

            SoundEffectInstance instance = SoundEffect.FromStream(Application.GetResourceStream(new Uri("Sound/piglet_puzzle/game_start.wav", UriKind.Relative)).Stream).CreateInstance();
            instance.Play();

            if (NavigationContext.QueryString.ContainsKey("typeLevel"))
            {
                this.typeLevel = NavigationContext.QueryString["typeLevel"].ToString();

            }
            if (NavigationContext.QueryString.ContainsKey("typeBackground"))
            {
                this.typeBackground = NavigationContext.QueryString["typeBackground"].ToString();

            }
            this.ImageExample.Source = new BitmapImage(new Uri("/Images/piglet_puzzle/" + this.typeBackground + "/original_thumbnail.png", UriKind.Relative));
            this.ImageOriginal.Source = new BitmapImage(new Uri("/Images/piglet_puzzle/" + this.typeBackground + "/original.png", UriKind.Relative));
            if (this.typeLevel == "medium")
            {
                sizeWidth = 3;
                sizeHeight = 3;
                this.GridPuzzle.Width = 480;
                this.GridPuzzle.Height = 480;
                this.ImageOriginal.Width = 480;
                this.ImageOriginal.Height = 480;
                arrItems = new int[3, 3];
            }
            else
            {
                sizeWidth = 4;
                sizeHeight = 4;
                this.GridPuzzle.Width = 480;
                this.GridPuzzle.Height = 480;
                this.ImageOriginal.Width = 480;
                this.ImageOriginal.Height = 480;
                arrItems = new int[4, 4];
            }

            for (int i = 0; i < sizeHeight; i++)
            {
                RowDefinition r = new RowDefinition();
                if (this.typeLevel == "medium")
                {
                    r.Height = new GridLength(160);
                }
                else
                {
                    r.Height = new GridLength(120);
                }
                GridPuzzle.RowDefinitions.Add(r);
            }
            for (int i = 0; i < sizeWidth; i++)
            {
                ColumnDefinition c = new ColumnDefinition();
                if (this.typeLevel == "medium")
                {
                    c.Width = new GridLength(160);
                }
                else
                {
                    c.Width = new GridLength(120);
                }
                GridPuzzle.ColumnDefinitions.Add(c);
            }

            int imageIndex = 1;
            this.emptyPoint = new Point(sizeWidth - 1, sizeHeight - 1);
            for (int i = 0; i < sizeHeight; i++)
            {
                for (int j = 0; j < sizeWidth; j++)
                {
                    this.puzzleImage = new Image();
                    if (this.typeLevel == "medium")
                    {
                        this.puzzleImage.Width = 160;
                        this.puzzleImage.Height = 160;
                    }
                    else
                    {
                        this.puzzleImage.Width = 120;
                        this.puzzleImage.Height = 120;
                    }
                    this.puzzleImage.RenderTransform = new TranslateTransform() { X = 0, Y = 0 };
                    this.puzzleImage.MouseLeftButtonDown += new MouseButtonEventHandler(puzzleImage_MouseLeftButtonDown);
                    this.puzzleImage.Tag = Convert.ToString(i) + Convert.ToString(j);
                    if (i == sizeHeight - 1 && j == sizeWidth - 1)
                    {
                        arrItems[i, j] = 0;
                        this.puzzleImage.Source = new BitmapImage(new Uri("/Images/piglet_puzzle/" + this.typeBackground + "/" + this.typeLevel + "/0.png", UriKind.Relative));
                        this.imageEmpty = this.puzzleImage;
                    }
                    else
                    {
                        arrItems[i, j] = imageIndex;
                        this.puzzleImage.Source = new BitmapImage(new Uri("/Images/piglet_puzzle/" + this.typeBackground + "/" + this.typeLevel + "/" + Convert.ToString(imageIndex) + ".png", UriKind.Relative));
                    }
                    Canvas.SetZIndex(this.puzzleImage, 3);
                    Grid.SetColumn(this.puzzleImage, j);
                    Grid.SetRow(this.puzzleImage, i);
                    this.GridPuzzle.Children.Add(this.puzzleImage);
                    imageIndex++;
                }
            }
            this.mixPuzzleItem();
            this.isGamePlay = true;
        }

        private void mixPuzzleItem()
        {
            const int UP_ITEM = 1, DOWN_ITEM = 2, LEFT_ITEM = 3, RIGHT_ITEM = 4;
            List<int> listAvailableStep = new List<int>();
            for (int i = 0; i < 50; i++)
            {
                listAvailableStep.Clear();
                int iInt = (int)this.emptyPoint.Y;
                int jInt = (int)this.emptyPoint.X;

                if (iInt + 1 < this.sizeHeight)
                {
                    listAvailableStep.Add(UP_ITEM);
                }
                if (iInt - 1 >= 0)
                {
                    listAvailableStep.Add(DOWN_ITEM);
                }
                if (jInt + 1 < this.sizeWidth)
                {
                    listAvailableStep.Add(RIGHT_ITEM);
                }
                if (jInt - 1 >= 0)
                {
                    listAvailableStep.Add(LEFT_ITEM);
                }

                int STEP = listAvailableStep[this.rnd.Next(0, listAvailableStep.Count)];
                switch (STEP)
                {
                    case UP_ITEM:
                        var images = this.GridPuzzle.Children.OfType<Image>();
                        foreach (var img in images)
                        {
                            if (Convert.ToString(img.Tag) == (Convert.ToString(iInt + 1) + Convert.ToString(jInt)))
                            {
                                ImageSource isrc = this.imageEmpty.Source;
                                this.imageEmpty.Source = img.Source;
                                img.Source = isrc;
                                this.arrItems[iInt, jInt] = this.arrItems[iInt + 1, jInt];
                                this.arrItems[iInt + 1, jInt] = 0;
                                this.imageEmpty = img;
                                this.emptyPoint.X = jInt;
                                this.emptyPoint.Y = iInt + 1;
                                break;
                            }

                        }

                        break;
                    case DOWN_ITEM:
                        images = this.GridPuzzle.Children.OfType<Image>();
                        foreach (var img in images)
                        {
                            if (Convert.ToString(img.Tag) == (Convert.ToString(iInt - 1) + Convert.ToString(jInt)))
                            {
                                ImageSource isrc = this.imageEmpty.Source;
                                this.imageEmpty.Source = img.Source;
                                img.Source = isrc;
                                this.arrItems[iInt, jInt] = this.arrItems[iInt - 1, jInt];
                                this.arrItems[iInt - 1, jInt] = 0;
                                this.imageEmpty = img;
                                this.emptyPoint.X = jInt;
                                this.emptyPoint.Y = iInt - 1;
                                break;
                            }

                        }

                        break;
                    case RIGHT_ITEM:
                        images = this.GridPuzzle.Children.OfType<Image>();
                        foreach (var img in images)
                        {
                            if (Convert.ToString(img.Tag) == (Convert.ToString(iInt) + Convert.ToString(jInt + 1)))
                            {
                                ImageSource isrc = this.imageEmpty.Source;
                                this.imageEmpty.Source = img.Source;
                                img.Source = isrc;
                                this.arrItems[iInt, jInt] = this.arrItems[iInt, jInt + 1];
                                this.arrItems[iInt, jInt + 1] = 0;
                                this.imageEmpty = img;
                                this.emptyPoint.X = jInt + 1;
                                this.emptyPoint.Y = iInt;
                                break;
                            }

                        }

                        break;
                    case LEFT_ITEM:
                        images = this.GridPuzzle.Children.OfType<Image>();
                        foreach (var img in images)
                        {
                            if (Convert.ToString(img.Tag) == (Convert.ToString(iInt) + Convert.ToString(jInt - 1)))
                            {
                                ImageSource isrc = this.imageEmpty.Source;
                                this.imageEmpty.Source = img.Source;
                                img.Source = isrc;
                                this.arrItems[iInt, jInt] = this.arrItems[iInt, jInt - 1];
                                this.arrItems[iInt, jInt - 1] = 0;
                                this.imageEmpty = img;
                                this.emptyPoint.X = jInt - 1;
                                this.emptyPoint.Y = iInt;
                                break;
                            }

                        }
                        break;
                }
            }

            if (this.sizeWidth - 1 != (int)this.emptyPoint.X || this.sizeHeight - 1 != (int)this.emptyPoint.Y)
            {
                int iInt = (int)this.emptyPoint.Y;
                int jInt = (int)this.emptyPoint.X;
                if (this.sizeWidth - 1 != this.emptyPoint.X)
                {
                    for (int j = (int)this.emptyPoint.X; j < this.sizeWidth - 1; j++)
                    {
                        var images = this.GridPuzzle.Children.OfType<Image>();
                        foreach (var img in images)
                        {
                            if (Convert.ToString(img.Tag) == (Convert.ToString(iInt) + Convert.ToString(j + 1)))
                            {
                                ImageSource isrc = this.imageEmpty.Source;
                                this.imageEmpty.Source = img.Source;
                                img.Source = isrc;
                                this.arrItems[iInt, j] = this.arrItems[iInt, j + 1];
                                this.arrItems[iInt, j + 1] = 0;
                                this.imageEmpty = img;
                                this.emptyPoint.X = j + 1;
                                this.emptyPoint.Y = iInt;
                                break;
                            }

                        }
                    }
                }
                jInt = (int)this.emptyPoint.X;
                if (this.sizeHeight - 1 != this.emptyPoint.Y)
                {
                    for (int i = (int)this.emptyPoint.Y; i < this.sizeHeight - 1; i++)
                    {
                        var images = this.GridPuzzle.Children.OfType<Image>();
                        foreach (var img in images)
                        {
                            if (Convert.ToString(img.Tag) == (Convert.ToString(i + 1) + Convert.ToString(jInt)))
                            {
                                ImageSource isrc = this.imageEmpty.Source;
                                this.imageEmpty.Source = img.Source;
                                img.Source = isrc;
                                this.arrItems[i, jInt] = this.arrItems[i + 1, jInt];
                                this.arrItems[i + 1, jInt] = 0;
                                this.imageEmpty = img;
                                this.emptyPoint.X = jInt;
                                this.emptyPoint.Y = i + 1;
                                break;
                            }

                        }
                    }
                }
            }
        }

        private void puzzleImage_MouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            if (!this.isGamePlay) return;
            Image item = sender as Image;

            string iStr = Convert.ToString(item.Tag).Substring(0, 1);
            int iInt = Convert.ToInt32(iStr);

            string jStr = Convert.ToString(item.Tag).Substring(1, 1);
            int jInt = Convert.ToInt32(jStr);

            List<int> neighborhood = new List<int>();
            if (this.arrItems[iInt, jInt] != 0)
            {
                bool replace = false;
                if (iInt + 1 < this.sizeHeight)
                {
                    if (this.arrItems[iInt + 1, jInt] == 0)
                    {
                        var images = this.GridPuzzle.Children.OfType<Image>();
                        foreach (var img in images)
                        {
                            if (Convert.ToString(img.Tag) == (Convert.ToString(iInt + 1) + Convert.ToString(jInt)))
                            {
                                ImageSource isrc = item.Source;
                                item.Source = img.Source;
                                img.Source = isrc;
                                this.arrItems[iInt + 1, jInt] = this.arrItems[iInt, jInt];
                                this.arrItems[iInt, jInt] = 0;
                                replace = true;
                                break;
                            }
                        }
                    }
                }
                if (iInt - 1 >= 0 && !replace)
                {
                    if (this.arrItems[iInt - 1, jInt] == 0)
                    {
                        var images = this.GridPuzzle.Children.OfType<Image>();
                        foreach (var img in images)
                        {
                            if (Convert.ToString(img.Tag) == (Convert.ToString(iInt - 1) + Convert.ToString(jInt)))
                            {
                                ImageSource isrc = item.Source;
                                item.Source = img.Source;
                                img.Source = isrc;
                                this.arrItems[iInt - 1, jInt] = this.arrItems[iInt, jInt];
                                this.arrItems[iInt, jInt] = 0;
                                replace = true;
                                break;
                            }
                        }
                    }
                }
                if (jInt + 1 < this.sizeWidth && !replace)
                {
                    if (this.arrItems[iInt, jInt + 1] == 0)
                    {
                        var images = this.GridPuzzle.Children.OfType<Image>();
                        foreach (var img in images)
                        {
                            if (Convert.ToString(img.Tag) == (Convert.ToString(iInt) + Convert.ToString(jInt + 1)))
                            {
                                ImageSource isrc = item.Source;
                                item.Source = img.Source;
                                img.Source = isrc;
                                this.arrItems[iInt, jInt + 1] = this.arrItems[iInt, jInt];
                                this.arrItems[iInt, jInt] = 0;
                                replace = true;
                                break;
                            }
                        }
                    }
                }
                if (jInt - 1 >= 0 && !replace)
                {
                    if (this.arrItems[iInt, jInt - 1] == 0)
                    {
                        var images = this.GridPuzzle.Children.OfType<Image>();
                        foreach (var img in images)
                        {
                            if (Convert.ToString(img.Tag) == (Convert.ToString(iInt) + Convert.ToString(jInt - 1)))
                            {
                                ImageSource isrc = item.Source;
                                item.Source = img.Source;
                                img.Source = isrc;
                                this.arrItems[iInt, jInt - 1] = this.arrItems[iInt, jInt];
                                this.arrItems[iInt, jInt] = 0;
                                replace = true;
                                break;
                            }
                        }
                    }
                }

            }
            item.CaptureMouse();

            if (this.puzzleImage_isValidPuzzle())
            {
                SoundEffectInstance instance = SoundEffect.FromStream(Application.GetResourceStream(new Uri("Sound/piglet_puzzle/game_complete.wav", UriKind.Relative)).Stream).CreateInstance();
                instance.Play();

                this.ImageOriginal.Visibility = Visibility.Visible;

                var images = this.GridPuzzle.Children.OfType<Image>();
                iInt = this.sizeHeight - 1;
                jInt = this.sizeWidth - 1;
                foreach (var img in images)
                {
                    if (Convert.ToString(img.Tag) == (Convert.ToString(this.sizeWidth - 1) + Convert.ToString(this.sizeHeight - 1)))
                    {
                        int imageIndex = this.sizeWidth * this.sizeHeight;
                        img.Source = new BitmapImage(new Uri("/Images/piglet_puzzle/" + this.typeBackground + "/" + this.typeLevel + "/" + Convert.ToString(imageIndex) + ".png", UriKind.Relative));
                        break;
                    }

                }
                Storyboard sb = new Storyboard();
                DoubleAnimation fadeInAnimation1 = new DoubleAnimation();
                fadeInAnimation1.From = 1;
                fadeInAnimation1.To = 0.0;
                fadeInAnimation1.Duration = new Duration(TimeSpan.FromSeconds(1.0));
                Storyboard.SetTarget(fadeInAnimation1, this.ImageOriginal);
                Storyboard.SetTargetProperty(fadeInAnimation1, new PropertyPath("(UIElement.Opacity)"));
                sb.Children.Add(fadeInAnimation1);
                sb.Begin();
                this.isGamePlay = false;
            }
        }

        protected override void OnNavigatingFrom(NavigatingCancelEventArgs e)
        {
            base.OnNavigatingFrom(e);

            IsolatedStorageSettings.ApplicationSettings["AnimationPigletPlay"] = "";
            IsolatedStorageSettings.ApplicationSettings.Save();
        }

        private bool puzzleImage_isValidPuzzle()
        {
            int indexImage = 1;
            string str = "";
            for (int i = 0; i < this.sizeHeight; i++)
            {
                for (int j = 0; j < this.sizeWidth; j++)
                {

                    str += Convert.ToString(indexImage);
                    if (i == this.sizeHeight - 1 && j == this.sizeWidth - 1)
                    {
                        if (this.arrItems[i, j] != 0) return false;
                    }
                    else
                        if (this.arrItems[i, j] != indexImage)
                        {
                            return false;
                        }
                    indexImage++;
                }
            }
            return true;
        }

        private void ImageExample_MouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            this.ImageOriginal.Visibility = Visibility.Visible;
        }

        private void ImageOriginal_MouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            this.ImageOriginal.Visibility = Visibility.Collapsed;
        }
    }
}